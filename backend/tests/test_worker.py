from datetime import datetime, timedelta

from app.core.security import hash_password
from app.db.models import CheckIn, CheckInStatus, User
from app.worker.tasks import process_single_checkin


def _make_checkin(db, email_suffix, deadline_offset_minutes, status=CheckInStatus.ACTIVE):
    user = User(email=f"worker-{email_suffix}@example.com", password_hash=hash_password("pass12345"))
    db.add(user)
    db.commit()
    db.refresh(user)

    checkin = CheckIn(
        user_id=user.id,
        name="Test check-in",
        message="msg",
        recipient_email="watcher@example.com",
        duration_minutes=10,
        deadline=datetime.utcnow() + timedelta(minutes=deadline_offset_minutes),
        status=status,
    )
    db.add(checkin)
    db.commit()
    db.refresh(checkin)
    return checkin


def test_expired_checkin_is_triggered(db_session):
    checkin = _make_checkin(db_session, "expired", deadline_offset_minutes=-5)

    process_single_checkin(checkin.id, db_session)
    db_session.refresh(checkin)

    assert checkin.status == CheckInStatus.TRIGGERED
    assert checkin.triggered_at is not None


def test_cancelled_checkin_is_not_triggered(db_session):
    checkin = _make_checkin(
        db_session, "cancelled", deadline_offset_minutes=-5, status=CheckInStatus.CANCELLED
    )

    process_single_checkin(checkin.id, db_session)
    db_session.refresh(checkin)

    assert checkin.status == CheckInStatus.CANCELLED
    assert checkin.triggered_at is None


def test_triggered_checkin_is_not_processed_again(db_session):
    checkin = _make_checkin(db_session, "once", deadline_offset_minutes=-5)

    process_single_checkin(checkin.id, db_session)
    db_session.refresh(checkin)
    first_triggered_at = checkin.triggered_at

    # Simulate the periodic task running again a minute later, as it would
    # in production, and confirm it's a no-op the second time.
    process_single_checkin(checkin.id, db_session)
    db_session.refresh(checkin)

    assert checkin.triggered_at == first_triggered_at
