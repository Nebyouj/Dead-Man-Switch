from datetime import datetime, timedelta
from typing import List

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app.api.deps import get_current_user
from app.core.config import settings
from app.db.database import get_db
from app.db.models import CheckIn, CheckInStatus, User
from app.schemas.checkin import CheckInCreate, CheckInOut

router = APIRouter(prefix="/checkins", tags=["checkins"])

def _get_owned_checkin(checkin_id: int, user: User, db: Session) -> CheckIn:
    """Fetch a check-in scoped to its owner.404s(never 403s) on mismatch
    so we don't leak whether the id exists for another user."""

    checkin = (
        db.query(CheckIn)
        .filter(CheckIn.id == checkin_id, CheckIn.user_id == user.id)
        .first()
    )
    if checkin is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Check-in not found")
    return checkin

@router.post("", response_model=CheckInOut, status_code=status.HTTP_201_CREATED)
def create_checkin(
    payload: CheckInCreate,
    user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    # The server always computes the deadline - the client only ever
    # supplies a duration, never a raw deadline
    deadline = datetime.utcnow() + timedelta(minutes=payload.duration_minutes)

    checkin = CheckIn(
        user_id=user.id,
        name=payload.name,
        message=payload.message,
        recipient_email=payload.recipient_email,
        recipient_phone=payload.recipient_phone,
        channels=[channel.value for channel in payload.channels],
        duration_minutes=payload.duration_minutes,
        deadline=deadline,
        status=CheckInStatus.ACTIVE,
    )
    db.add(checkin)
    db.commit()
    db.refresh(checkin)
    return checkin

@router.get("", response_model=list[CheckInOut])
def list_checkins(user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    return (
        db.query(CheckIn)
        .filter(CheckIn.user_id == user.id)
        .order_by(CheckIn.created_at.desc())
        .all()
    )

@router.get("/{checkin_id}", response_model=CheckInOut)
def get_checkin(checkin_id: int, user = Depends(get_current_user), db: Session = Depends(get_db)):
    return _get_owned_checkin(checkin_id, user, db)


@router.post("/{checkin_id}/check-in", response_model=CheckInOut)
def reset_checkin(checkin_id: int, user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    checkin = _get_owned_checkin(checkin_id, user, db)

    if checkin.status != CheckInStatus.ACTIVE:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"check-in is not a {checkin.status.value.lower()} check-in",
        )

    checkin.deadline = datetime.utcnow() + timedelta(minutes=checkin.duration_minutes)
    checkin.notification_attempts = 0
    db.commit()
    db.refresh(checkin)
    return checkin


@router.post("/{checkin_id}/cancel", response_model=CheckInOut)
def cancel_checkin(checkin_id: int, user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    checkin = _get_owned_checkin(checkin_id, user, db)

    if checkin.status != CheckInStatus.ACTIVE:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"check-in is not in a {checkin.status.value.lower()} state and cannot be cancelled",
        )

    checkin.status = CheckInStatus.CANCELLED
    db.commit()
    db.refresh(checkin)
    return checkin


@router.delete("/{checkin_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_checkin(checkin_id: int, user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    checkin = _get_owned_checkin(checkin_id, user, db)
    db.delete(checkin)
    db.commit()
    return None

@router.post("/{checkin_id}/trigger", response_model=CheckInOut)
def trigger_checkin(checkin_id: int, user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    """ Development-only: manully fire the expiry pipeline for one check-in
    so you can see the full flow(worker logic + notification) without
    waiting for the real deadline. Disabled whenever DEBUG is false."""

    if not settings.DEBUG:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Manual trigger is disabled outside DEBUG mode",
        )

    checkin = _get_owned_checkin(checkin_id, user, db)

    if checkin.status != CheckInStatus.ACTIVE:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Cannot trigger a { checkin.status.value.lower()} check-in"
        )

    # Local import: keeps the workers package free of any dependency on the
    # API package, so 'celery -A app.worker.celery_app worker' never needs
    # to import FastAPI routers.

    from app.worker.tasks import process_single_checkin

    process_single_checkin(checkin_id, db)
    db.refresh(checkin)
    return checkin  