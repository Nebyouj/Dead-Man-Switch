import sys
from app.db.database import SessionLocal
from app.db.models import User, UserRole

def make_admin(email: str):
    db = SessionLocal()
    try:
        user = db.query(User).filter(User.email == email).first()
        if not user:
            print(f"Error: User with email '{email}' not found.")
            return

        user.role = UserRole.ADMIN
        db.commit()
        print(f"Success! User '{email}' has been promoted to ADMIN.")
    finally:
        db.close()

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python make_admin.py <user_email>")
        sys.exit(1)
    
    make_admin(sys.argv[1])
