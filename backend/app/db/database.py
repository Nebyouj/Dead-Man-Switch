from sqlalchemy import create_engine
from sqlalchemy.orm import declarative_base, sessionmaker

from app.core.config import settings

# SQlite (used in tests) needs this flag; Postgres ignores it if passwd, so
# we only set it conditionally to keep the engine args clean either way.
connect_args = {"check_same_thread:" : False} if settings.DATABASE_URL.startswith("sqlite") else {}

engine = create_engine(settings.DATABASE_URL, connect_args=connect_args)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

Base = declarative_base()

def get_db():
    bd = SessionLocal()
    try:
        yield bd
    finally:
        bd.close()