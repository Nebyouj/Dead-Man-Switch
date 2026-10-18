import logging

import requests

from app.core.config import settings
from app.services.providers.base import NotificationError, NotificationProvider

logger = logging.getLogger("deadmanswitch.notifcation.sms")

class SMSProvider(NotificationProvider):
    """SMS via AfroMessage (https://afromesage.com)

    NOTE: Afromessage's public docs page is JS-rendered and wasn't fetchable
    at write time, so this is built from their published SDKs(Go/PHP/Node)
    rather than the primary reference doc.The request/response shape below
    matches every SDK example found('to', 'message', 'from', 'sender' as 
    query params against GET /api/send, Bearer-token auth, an 'acknowledge'
    field that's "success on success) - but double check it against your 
    AfroMessage dashboard before relying on it, since thrid-party API
    details can drift.
    """

    API_URL = "https://api.afromessage.com/api/send"

    def send(self, recipient: str, subject: str, message: str) -> None:
        if not settings.AFROMESSAGE_API_KEY:
            # No API key configured(e.g. local dev) - log instead of
            # failing the whole pipeline, same as the email provider.

            logger.info(
                "AfroMessage not configured; logging SMS instead of sending. To: %s",
                recipient,
            )
            logger.info("Message body: \n%s", message)
            return

        #SMS has no subject line - fold it into the body if present.
        body = f"{subject}: {message}" if subject else message

        params = {"to": recipient, "message": body}
        if settings.AFROMESSAGE_IDENTIFIER_ID:
            params["from"] = settings.AFROMESSAGE_IDENTIFIER_ID
        if settings.AFROMESSAGE_SENDER_NAME:
            params["sender"] = settings.AFROMESSAGE_SENDER_NAME

        try:
            response = requests.get(
                self.API_URL,
                params=params,
                headers={"Authorization": f"Bearer {settings.AFROMESSAGE_API_KEY}"},
                timeout=10,
            )
            response.raise_for_status()
            payload = response.json()

        except(requests.RequestException, ValueError) as exc:
            logger.error("Failed to send SMS to %s: %s", recipient, exc)
            raise NotificationError(str(exc)) from exc

        if payload.get("acknowledge") != "success":
            logger.error("SMS send acknowledged as non-success. Response: %s", payload)
            raise NotificationError(f"API acknowledged non-success: {payload.get('error', 'Unknown error')}")