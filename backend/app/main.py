import logging

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.api import admin, auth, checkins
from app.db.database import Base, engine

logging.basicConfig(level=logging.INFO, format="%(asctime)s %(levelname)s %(name)s: %(message)s")

# For a one-day project, create_all() is fine. For anything longer-lived,
# swap this for Alembic migrations.
Base.metadata.create_all(bind=engine)

app = FastAPI(
    title="Dead Man's Switch",
    description="A check-in timer that notifies someone if you don't check in before your deadline.",
    version="1.0.0",
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(auth.router)
app.include_router(checkins.router)
app.include_router(admin.router)

@app.get("/health", tags=["health"])
def health_check():
    return {"status": "ok"}