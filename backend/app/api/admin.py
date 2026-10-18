from typing import List
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session, joinedload

from app.api.deps import get_current_admin_user
from app.db.database import get_db
from app.db.models import CheckIn, CheckInStatus, User
from app.schemas.checkin import AdminCheckInOut
from app.schemas.user import UserOut, UserRoleUpdate
from app.schemas.admin import SystemStatsOut
from sqlalchemy import func

router = APIRouter(prefix="/admin", tags=["admin"])

@router.get("/users", response_model= List[UserOut])
def list_users(admin: User = Depends(get_current_admin_user), db: Session = Depends(get_db)):
    return db.query(User).order_by(User.created_at.desc()).all()

@router.get("/checkins", response_model=List[AdminCheckInOut])
def list_all_checkins(admin: User = Depends(get_current_admin_user), db: Session = Depends(get_db)):
    # joinedload avoids one extra query per row just to read .user.email -
    # relevant here since, unlike the regular /checkins list, this one
    # isn't scoped to single user and can return every check-in there is.

    return (
        db.query(CheckIn)
        .options(joinedload(CheckIn.user))
        .order_by(CheckIn.created_at.desc())
        .all()
    )

@router.post("/checkins/{checkin_id}/cancel", response_model = AdminCheckInOut)
def force_cancel_checkin(
    checkin_id: int,
    admin: User = Depends(get_current_admin_user),
    db: Session = Depends(get_db),
):
    """Unlike the regular /checkins/{id}/cancel, this isn't scoped to the 
    caller's own check-ins - an admin can cancel anyones's"""
    checkin = (
        db.query(CheckIn)
        .options(joinedload(CheckIn.user))
        .filter(CheckIn.id == checkin_id)
        .first()
    )

    if checkin is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Check-in not found")

    if checkin.status != CheckInStatus.ACTIVE:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Check-in is not active (status={checkin.status})",
        )

    checkin.status = CheckInStatus.CANCELLED
    db.commit()
    db.refresh(checkin)
    return checkin


@router.delete("/users/{user_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_user(
    user_id: int,
    admin: User = Depends(get_current_admin_user),
    db: Session = Depends(get_db),
):
    user = db.query(User).filter(User.id == user_id).first()
    if not user:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="User not found")
    
    db.query(CheckIn).filter(CheckIn.user_id == user_id).delete()
    db.delete(user)
    db.commit()
    return None

@router.put("/users/{user_id}/role", response_model=UserOut)
def update_user_role(
    user_id: int,
    role_update: UserRoleUpdate,
    admin: User = Depends(get_current_admin_user),
    db: Session = Depends(get_db),
):
    user = db.query(User).filter(User.id == user_id).first()
    if not user:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="User not found")
    
    user.role = role_update.role
    db.commit()
    db.refresh(user)
    return user

@router.get("/stats", response_model=SystemStatsOut)
def get_system_stats(
    admin: User = Depends(get_current_admin_user),
    db: Session = Depends(get_db),
):
    total_users = db.query(func.count(User.id)).scalar()
    total_active_checkins = db.query(func.count(CheckIn.id)).filter(CheckIn.status == CheckInStatus.ACTIVE).scalar()
    total_triggered_checkins = db.query(func.count(CheckIn.id)).filter(CheckIn.status == CheckInStatus.TRIGGERED).scalar()
    
    return SystemStatsOut(
        total_users=total_users,
        total_active_checkins=total_active_checkins,
        total_triggered_checkins=total_triggered_checkins,
    )

