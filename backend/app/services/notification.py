from app.services.providers.base import NotificationError, NotificationProvider
from app.services.providers.email_provider import EmailProvider
from app.services.providers.sms_provider import SMSProvider

__all__ = ["NotificationError", "send_notification"]

_PROVIDERS: dict[str, NotificationProvider] = {
    "email": EmailProvider(),
    "sms": SMSProvider(),
}


def send_notification(channel: str, recipient: str, subject: str, message: str) -> None:
    """Send through a single named channel. Raises NotificationError if the
    channel is unknown or the provider itself fails."""
    provider = _PROVIDERS.get(channel)
    if provider is None:
        raise NotificationError(f"Unknown notification channel: {channel!r}")
    provider.send(recipient, subject, message)
