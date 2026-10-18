from abc import ABC, abstractmethod

class NotificationError(Exception):
    """Raised when a notification could not be delivered by a provider."""

class NotificationProvider(ABC):
    """A single delivery channel (email, SMS, ...). Implementations should
    raise NotificationError on any failure to send - never sswallow it -
    so the worker can decide whether to retry."""

    @abstractmethod
    def send(self, recipient: str, subject: str, message: str) -> None:
        pass