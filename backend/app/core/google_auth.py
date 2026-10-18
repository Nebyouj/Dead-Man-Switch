from fastapi import HTTPException, status
from google.auth.transport import requests as google_requests
from google.oauth2 import id_token as google_id_token

from app.core.config import settings

def verify_google_token(token:str) -> dict:
    """Verify a Google Sign-In ID token and return it s decoded claims.

    Checks the tokem's signature, expiry, and that it was issued for our own GOOGLE_CLIENT_ID(so a token minted
    for a different app can't be replayed here). Raises HTTPExecption(401) on any failure.
    """

    if not settings.GOOGLE_CLIENT_ID:
        raise HTTPException(
            status_code= status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="Google sign-in is not configured on this server."
        )

    try:
        idinfo = google_id_token.verify_oauth2_token(
            token, google_requests.Request(), settings.GOOGLE_CLIENT_ID
        )
    except ValueError as exc:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid Google token",
        ) from exc

    if idinfo.get("email_verified") is False:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Google account email is not verified."
        )
    return idinfo