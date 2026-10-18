import enum
from datetime import datetime

from sqlalchemy import JSON, Column, DateTime, Enum, ForeignKey, Index, Integer, String, Text
from sqlalchemy.orm import relationship

from app.db.database import Base

class CheckInStatus(str, enum.Enum):
    ACTIVE = "ACTIVE"
    TRIGGERED = "TRIGGERED"
    CANCELLED = "CANCELLED"

class NotificationChannel(str, enum.Enum):
    EMAIL = "email"
    SMS = "sms"

class UserRole(str, enum.Enum):
    USER = "USER"
    ADMIN = "ADMIN"

class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)
    email = Column(String, unique=True, index=True, nullable=False)
    password_hash = Column(String, nullable=True)
    google_id = Column(String, unique=True, nullable=True, index=True)
    role = Column(Enum(UserRole), default=UserRole.USER, nullable=False)
    created_at = Column(DateTime, default=datetime.utcnow)

    checkins = relationship("CheckIn", back_populates="user")

class CheckIn(Base):
    __tablename__ = "checkins"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False)

    name = Column(String, nullable=False)
    message = Column(Text, nullable=False)
    recipient_email = Column(String, nullable=True)
    recipient_phone = Column(String, nullable=True)

    channels = Column(JSON, nullable=False, default=lambda: [NotificationChannel.EMAIL.value])

    #stored so the check-in/reset endpoint can recompute "now + original
    # duration" without the client having to resend it.
    duration_minutes = Column(Integer, nullable= False)
    deadline = Column(DateTime, nullable=False)

    status = Column(Enum(CheckInStatus), default=CheckInStatus.ACTIVE, nullable=False)

    notification_attempts = Column(Integer, default=0, nullable=False)

    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    triggered_at = Column(DateTime, nullable=True)
    
    user = relationship("User", back_populates="checkins")

    __table_args__ = (
        # the worker's hot-path query filters on exactly these two columns
        Index("ix_checkins_status_deadline", "status", "deadline"),
    )

    @property
    def user_email(self) -> str:
        """Convenience accessor for admin views that list check-ins across
        every user - lets AdminCheckInOut map straight off the ORM object
        without a separate join query in the schema layer."""
        return self.user.email if self.user else None