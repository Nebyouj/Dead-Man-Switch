import logging
from datetime import datetime, timezone
from typing import Tuple

from sqlalchemy.orm import Session

from app.db.database import SessionLocal
from app.db.models import CheckIn, CheckInStatus
from app.services.notification import NotificationError, send_notification
from app.worker.celery_app import celery_app

logger = logging.getLogger("deadmansswitch.worker")

MAX_NOTIFICATION_ATTEMPTS = 3

_RECIPIENT_FIELD = {
    "email": "recipient_email",
    "sms": "recipient_phone"
}


def build_email(checkin: CheckIn) -> Tuple[str, str]:
    """
    Return (subject, body) for a notification email for the given check-in.

    The body includes a link to cancel the check-in. In a production
    application, this URL should be authenticated/signed.
    """
    subject = "Dead Man's Switch Alert"

    body = (
        f"Hello,\n\n"
        f"This is an alert from your Dead Man's Switch. "
        f"The check-in '{checkin.name}' (ID: {checkin.id}) has expired "
        f"and we were unable to reset/validate it in time.\n\n"
        f"The original message was: "
        f"{checkin.message or '(not set)'}\n\n"
        f"You can cancel a check-in by visiting the following URL "
        f"(in a real app, this would be authenticated):\n"
        f"http://localhost:8000/api/v1/checkins/{checkin.id}/cancel\n\n"
        f"Deadline:\n"
        f"{checkin.deadline.strftime('%B %d, %Y %H:%M')}\n\n"
        f"Thank you!\n"
    )

    return subject, body


def process_single_checkin(checkin_id: int, db: Session) -> None:
    """
    Attempt to notify and mark a single expired check-in as TRIGGERED.

    Only ACTIVE check-ins are processed. This prevents duplicate
    notifications when multiple workers or scheduler runs encounter
    the same check-in.

    Notification attempts are limited by MAX_NOTIFICATION_ATTEMPTS.
    """

    checkin = (
        db.query(CheckIn)
        .filter(
            CheckIn.id == checkin_id,
            CheckIn.status == CheckInStatus.ACTIVE,
        )
        .with_for_update()
        .first()
    )

    if checkin is None:
        # Already triggered/cancelled by another process,
        # or the check-in does not exist.
        return

    # Prevent infinite retries.
    if checkin.notification_attempts >= MAX_NOTIFICATION_ATTEMPTS:
        logger.error(
            "Maximum notification attempts (%s) reached for check-in %s",
            MAX_NOTIFICATION_ATTEMPTS,
            checkin.id,
        )
        return

    subject, body = build_email(checkin)
    
    any_channel_succeeded = False
    for channel in checkin.channels:
        recipient_field = _RECIPIENT_FIELD.get(channel)
        recipient = getattr(checkin, recipient_field, None) if recipient_field else None
        if not recipient:
            logger.error("Check-in %s has channel %r but no recipient set for it", checkin.id, channel)
            continue

        try:
            send_notification(channel, recipient, subject, body)
            any_channel_succeeded = True
        except NotificationError:
            logger.warning("Notification via %s failed for check-in %s", channel, checkin.id)

    if not any_channel_succeeded:
        checkin.notification_attempts += 1
        db.commit()
        logger.warning(
            "All channels failed (attempt %s/%s) for check-in %s",
            checkin.notification_attempts,
            MAX_NOTIFICATION_ATTEMPTS,
            checkin.id,
        )
        return


    # Notification was successfully sent.
    checkin.status = CheckInStatus.TRIGGERED
    checkin.triggered_at = datetime.now(timezone.utc)

    db.commit()

    logger.info(
        "Successfully notified check-in %s and marked it as TRIGGERED",
        checkin.id,
    )


@celery_app.task(
    name="app.worker.tasks.process_expired_checkins",
    max_retries=MAX_NOTIFICATION_ATTEMPTS,
    default_retry_delay=30,
)
def process_expired_checkins():
    """
    Periodically find expired ACTIVE check-ins and process them.

    Celery Beat runs this task according to the schedule configured
    in celery_app.py.
    """

    db = SessionLocal()

    try:
        now = datetime.now(timezone.utc)

        expired = (
            db.query(CheckIn)
            .filter(
                CheckIn.status == CheckInStatus.ACTIVE,
                CheckIn.deadline <= now,
                CheckIn.notification_attempts < MAX_NOTIFICATION_ATTEMPTS,
            )
            .all()
        )

        logger.info(
            "Found %s expired check-in(s) requiring notification",
            len(expired),
        )

        for checkin in expired:
            try:
                process_single_checkin(
                    checkin.id,
                    db,
                )

            except Exception:
                db.rollback()

                logger.exception(
                    "Unexpected error while processing check-in %s",
                    checkin.id,
                )

    finally:
        db.close()