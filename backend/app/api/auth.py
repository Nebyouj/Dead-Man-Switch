from fastapi import APIRouter, Depends, HTTPException, status
from fastapi.security import OAuth2PasswordRequestForm
from sqlalchemy.orm import Session

from app.api.deps import get_current_user

from app.core.google_auth import verify_google_token
from app.core.security import create_access_token, hashed_password, verify_password
from app.db.database import get_db
from app.db.models import User
from app.schemas.auth import Token, GoogleAuthRequest
from app.schemas.user import UserCreate, UserOut

router = APIRouter(prefix="/auth", tags=["auth"])

@router.post("/register", response_model=UserOut, status_code=status.HTTP_201_CREATED)
def register(payload: UserCreate, db:Session = Depends(get_db)):
    existing = db.query(User).filter(User.email == payload.email).first()
    if existing:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Email already registered")

    user = User(email=payload.email, password_hash = hashed_password(payload.password))
    db.add(user)
    db.commit()
    db.refresh(user)
    return user    


@router.post("/login", response_model=Token)
def login(form_data:OAuth2PasswordRequestForm = Depends(), db: Session = Depends(get_db)):
    # OAuth2PasswordRequestForm's field is called "username" by spec, but we
    # treat it as the user's email - this also makes Swagger's "Authorize"
    # button work out of the box.abs

    user = db.query(User).filter(User.email == form_data.username).first()
    if not user or not verify_password(form_data.password, user.password_hash):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Incorrect email or password",
            headers={"WWW-Authenticate": "Bearer"},
        )

    access_token = create_access_token(subject=user.email)
    return Token(access_token=access_token, token_type="bearer")

@router.post("/google", response_model=Token)
def google_login(payload: GoogleAuthRequest, db:Session =Depends(get_db)):
    """Sign in(or sign up) with a Google ID token. Issues the same kind of JWT as /auth/login, 
    so nothing downstream needs to know which method the user signed in with."""

    idinfo = verify_google_token(payload.id_token)
    google_id = idinfo["sub"]
    email = idinfo["email"]

    user = db.query(User).filter(User.google_id == google_id).first()

    if user is None:
        # No account linked to this Google id yeet. if an emmail/password
        # account already exist with the same email, link this Google id
        # to it rather than creating a dupilate account.
        user = db.query(User).filter(User.email == email).first()
        if user is not None:
            user.google_id = google_id
        else:
            user = User(email=email, google_id=google_id, password_hash=None)
            db.add(user)
        db.commit()
        db.refresh(user)

    access_token = create_access_token(subject=user.email)
    return Token(access_token=access_token)

@router.get("/me", response_model=UserOut)
def get_me(current_user: User = Depends(get_current_user)):
    return current_user