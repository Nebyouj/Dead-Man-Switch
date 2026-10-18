from celery import Celery

from app.core.config import settings

celery_app = Celery(
    "deadmansswitch",
    broker=settings.REDIS_URL,
    backend=settings.REDIS_URL,
    include=["app.worker.tasks"],
)

celery_app.conf.update(
    task_serializer="json",
    accept_content=["json"],
    result_serializer="json",
    timezone="UTC",
    enable_utc=True,
)

# Periodic scan for expired check-ins. Run this process with:
# celery -A app.worker.celery_app beat --longlevel=info
celery_app.conf.beat_schedule = {
    "process-expired-checkins": {
        "task" : "app.worker.tasks.process_expired_checkins",
        "schedule" : settings.CHECKIN_POLL_INTERVAL_SECONDS,
    }
}

