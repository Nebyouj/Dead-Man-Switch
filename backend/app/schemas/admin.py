from pydantic import BaseModel

class SystemStatsOut(BaseModel):
    total_users: int
    total_active_checkins: int
    total_triggered_checkins: int
