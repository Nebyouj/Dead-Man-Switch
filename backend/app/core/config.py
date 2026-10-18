from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    model_config = SettingsConfigDict(
        case_sensitive=True, env_prefix="", extra="ignore"
    )
    
    # Debug mode also gates the dev-only manual trigger endpoints. Set to
    # false in production.
    DEBUG: bool = True

    DATABASE_URL: str = "postgresql://postgres:5028@db:5432/dead_mans_switch"
    REDIS_URL: str = "redis://redis:6379/0"
    
    SECRET_KEY: str = "change-me-to-a-random-sercet"
    ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 60 * 24  # 1 day

    SMTP_HOST: str = ""
    SMTP_PORT: int = 587
    SMTP_USERNAME: str = ""
    SMTP_PASSWORD: str = ""
    SMTP_FROM: str = "[EMAIL_ADDRESS]"

    # SMS via AfroMessage (https://afromessage.com). Leave AFROMESSAGE_API_KEY
    # blank to log SMS instead of sending, same as SMTP_HOST above.
    AFROMESSAGE_API_KEY: str = ""
    AFROMESSAGE_SENDER_NAME: str = ""
    AFROMESSAGE_IDENTIFIER_ID: str = ""

    # Google Sign-In. This is the OAuth client ID (not secret) from Google
    # Cloud Console — used to verify the audience of incoming ID tokens.
    GOOGLE_CLIENT_ID: str = ""
    
    # How often (in seconds) the Celery beat schedule fires the tast that
    # scans for expired check-ins.
    CHECKIN_POLL_INTERVAL_SECONDS: int = 10
    

settings = Settings()