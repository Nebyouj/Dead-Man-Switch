import logging
import smtplib
from email.message import EmailMessage


from app.services.providers.base import NotificationError, NotificationProvider
from app.core.config import settings

logger = logging.getLogger("deadmanswitich.notification.email")

class EmailProvider(NotificationProvider):
    def send(self, recipient: str, subject: str, message:str) -> None:
        if not settings.SMTP_HOST:
            # No SMTP configured(e.g local dev without real credentials) -
            # log instead of failing the whole pipeline. 

            logger.info(
                "SMTP not configured; logging notification instead odf sending. To: %s | Subject: %s",
                recipient, 
                subject
            )
            logger.info("Message body: \n%s", message)
            return
        
        email_message = EmailMessage()
        email_message["Subject"] = subject
        email_message["From"] = settings.SMTP_FROM
        email_message["To"] = recipient
        email_message.set_content(message)

        try:
            if settings.SMTP_PORT == 465:
                # port 465 is implicit TLS: the server expects an encrypted
                # connection from the very first byte. A plaintext EHLO
                # first (the STARTTTLS branch below) makes it hang up
                # immediately - that's the "connection unexpectedly
                # closed" error

                with smtplib.SMTP_SSL(settings.SMTP_HOST, settings.SMTP_PORT, timeout=10) as smtp:
                    if settings.SMTP_USERNAME:
                        smtp.login(settings.SMTP_USERNAME, settings.SMTP_PASSWORD)
                    smtp.send_message(email_message)
                    logger.info("Email notification sent to: %s", recipient)
            else:
                # starttls: explicit TLS
                with smtplib.SMTP(settings.SMTP_HOST, settings.SMTP_PORT, timeout=10) as smtp:
                    # smtp.ehlo()
                    smtp.starttls()
                    if settings.SMTP_USERNAME:
                        smtp.login(settings.SMTP_USERNAME, settings.SMTP_PASSWORD)
                    smtp.send_message(email_message)
                    logger.info("Email notification sent to: %s", recipient)
        
        except smtplib.SMTPException as e:
            logger.error("Failed to send email to %s: %s", recipient, e)
            raise NotificationError(f"SMTP error: {e}") from e
            
                
                    