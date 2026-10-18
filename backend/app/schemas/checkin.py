from datetime import datetime
from typing import Optional

from pydantic import BaseModel, ConfigDict, EmailStr, Field, model_validator

from app.db.models import CheckInStatus, NotificationChannel
from app.schemas.user import UserOut

class CheckInCreate(BaseModel):
    name: str = Field(..., min_length=1, max_length=255)
    message: Optional[str] = None
    recipient_email: Optional[EmailStr] = None
    recipient_phone: Optional[str] = None
    channels: list[NotificationChannel] = Field(default_factory=lambda: [NotificationChannel.EMAIL])
    duration_minutes: int = Field(
        ..., gt=0, description="Minutes until this check_in expires if not reset"   
    )

    @model_validator(mode="after")
    def _require_recipient_per_channel(self) -> "CheckInCreate":
        if not self.channels:
            raise ValueError("channels must include at least one notification channel")
        if NotificationChannel.EMAIL in self.channels and not self.recipient_email:
            raise ValueError("recipient_email is required when 'email' is one of the channels")
        if NotificationChannel.SMS in self.channels and not self.recipient_phone:
            raise ValueError("recipient_phone is required when 'sms' is one of the channels")
        if not self.recipient_email and not self.recipient_phone:
            raise ValueError(
                "At least one of recipient_email or recipient_phone must be provided"
            )
        return self
    
class CheckInOut(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: int
    name: str
    message: Optional[str] = None
    recipient_email: Optional[EmailStr] = None
    recipient_phone: Optional[str] = None
    channels: list[NotificationChannel]
    duration_minutes: int
    deadline: datetime
    status: CheckInStatus
    created_at: datetime
    updated_at: datetime
    triggered_at: Optional[datetime] = None

class AdminCheckInOut(CheckInOut):
    user: UserOut