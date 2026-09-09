import os
import uuid
from typing import Dict, List, Optional
from fastapi import APIRouter, HTTPException, Query, Header
from ..models.schemas import (
    UserRegisterRequest, UserLoginRequest, UserProfile,
    FarmModel, AuthResponse, CropSelectionUpdateRequest
)
from ..core import database

router = APIRouter(tags=["Authentication & Farmer Profile"])

ALLOWED_CROPS = ["Onion", "Grapes", "Sugarcane", "Wheat"]

def _extract_token(
    token: Optional[str] = None,
    authorization: Optional[str] = None,
    x_token: Optional[str] = None
) -> Optional[str]:
    if token and token != "demo_token_secret_123":
        return token
    if authorization:
        if authorization.lower().startswith("bearer "):
            return authorization[7:].strip()
        return authorization.strip()
    if x_token:
        return x_token.strip()
    if token == "demo_token_secret_123":
        return token
    return None

def _resolve_user(token_str: Optional[str]) -> dict:
    if token_str:
        user = database.get_user_by_token(token_str)
        if user:
            return user
    
    # Fallback to the latest active user in SQLite database
    latest = database.get_latest_active_user()
    if latest:
        return latest
    
    # Fallback to default demo user
    demo_user = database.get_user_by_mobile("9876543210")
    if demo_user:
        return demo_user
    
    raise HTTPException(status_code=404, detail="No user found in database.")

@router.post("/auth/register", response_model=AuthResponse)
@router.post("/register", response_model=AuthResponse)
def register_user(req: UserRegisterRequest):
    if not req.name.strip():
        raise HTTPException(status_code=400, detail="Please enter your full name.")
    if not req.mobile.strip() or len(req.mobile.strip()) < 10:
        raise HTTPException(status_code=400, detail="Please enter a valid 10-digit mobile number.")
    if not req.password or len(req.password) < 4:
        raise HTTPException(status_code=400, detail="Password must be at least 4 characters long.")

    selected = [c for c in (req.selected_crops or ["Grapes", "Onion"]) if c in ALLOWED_CROPS]
    if not selected:
        selected = ["Grapes", "Onion"]

    user_id = f"usr_{uuid.uuid4().hex[:8]}"
    farm_id = f"frm_{uuid.uuid4().hex[:8]}"

    initial_farm = {
        "farm_id": farm_id,
        "user_id": user_id,
        "farm_name": f"{req.name}'s Farm",
        "village": req.village or "Pune",
        "district": req.district or "Pune",
        "state": req.state or "Maharashtra",
        "latitude": 19.9975,
        "longitude": 73.7898,
        "area": req.farm_size_acres or 2.5,
        "area_unit": "Acres",
        "soil_type": "Clay loam",
        "irrigation_type": "Drip Irrigation",
    }

    user = {
        "id": user_id,
        "name": req.name.strip(),
        "email": req.email or f"{req.mobile}@agriintel.in",
        "mobile": req.mobile.strip(),
        "password": req.password,
        "village": req.village or "Pune",
        "district": req.district or "Pune",
        "state": req.state or "Maharashtra",
        "farm_size_acres": req.farm_size_acres or 2.5,
        "selected_crops": selected,
        "language": req.language or "mr",
        "farming_experience_years": req.farming_experience_years or 5,
        "farms": [initial_farm],
        "is_demo": False,
        "verification_status": "VERIFIED"
    }

    saved_user = database.save_user(user)

    token = f"token_{uuid.uuid4().hex}"
    database.create_session(token, req.mobile.strip(), user_id)

    profile = UserProfile(**saved_user)
    return AuthResponse(token=token, user=profile, verification_status="VERIFIED")

@router.post("/auth/login", response_model=AuthResponse)
@router.post("/login", response_model=AuthResponse)
def login_user(req: UserLoginRequest):
    login_id = req.login.strip()
    if not login_id:
        raise HTTPException(status_code=400, detail="Please enter your registered mobile number or email.")
    if not req.password:
        raise HTTPException(status_code=400, detail="Please enter your password.")

    user = database.get_user_by_mobile(login_id) or database.get_user_by_email(login_id)

    if not user:
        # Auto-create user profile in SQLite database if first-time quick login
        user_id = f"usr_{uuid.uuid4().hex[:8]}"
        is_phone = login_id.isdigit()
        mobile = login_id if is_phone else f"98{uuid.uuid4().hex[:8]}"
        email = login_id if "@" in login_id else f"{login_id}@agriintel.in"

        user = {
            "id": user_id,
            "name": f"Farmer ({login_id})",
            "email": email,
            "mobile": mobile,
            "password": req.password,
            "village": "Pune",
            "district": "Pune",
            "state": "Maharashtra",
            "farm_size_acres": 3.0,
            "selected_crops": ["Grapes", "Onion"],
            "language": "mr",
            "farming_experience_years": 5,
            "farms": [
                {
                    "farm_id": f"frm_{uuid.uuid4().hex[:8]}",
                    "user_id": user_id,
                    "farm_name": "My Farm",
                    "village": "Pune",
                    "district": "Pune",
                    "state": "Maharashtra",
                    "latitude": 18.5204,
                    "longitude": 73.8567,
                    "area": 3.0,
                    "area_unit": "Acres",
                    "soil_type": "Medium Black Clay Loam",
                    "irrigation_type": "Drip Irrigation",
                }
            ],
            "is_demo": False,
            "verification_status": "VERIFIED"
        }
        user = database.save_user(user)

    token = f"token_{uuid.uuid4().hex}"
    database.create_session(token, user["mobile"], user["id"])

    profile = UserProfile(**user)
    return AuthResponse(token=token, user=profile, verification_status=profile.verification_status)

@router.get("/auth/profile", response_model=UserProfile)
@router.get("/auth/me", response_model=UserProfile)
@router.get("/profile", response_model=UserProfile)
def get_current_profile(
    token: Optional[str] = Query(None),
    authorization: Optional[str] = Header(None),
    x_token: Optional[str] = Header(None)
):
    token_str = _extract_token(token, authorization, x_token)
    user = _resolve_user(token_str)
    return UserProfile(**user)

@router.put("/auth/profile", response_model=UserProfile)
@router.put("/profile", response_model=UserProfile)
@router.post("/auth/profile", response_model=UserProfile)
def update_profile(
    updated: UserProfile,
    token: Optional[str] = Query(None),
    authorization: Optional[str] = Header(None),
    x_token: Optional[str] = Header(None)
):
    token_str = _extract_token(token, authorization, x_token)
    current = None
    if token_str:
        current = database.get_user_by_token(token_str)
    
    if not current:
        current = database.get_user_by_mobile(updated.mobile) or database.get_latest_active_user()

    data = updated.model_dump()
    if current:
        data["id"] = current["id"]
        # keep farms if not explicitly replaced
        if not data.get("farms") and current.get("farms"):
            data["farms"] = current["farms"]

    saved = database.save_user(data)
    if token_str:
        database.create_session(token_str, saved["mobile"], saved["id"])
    else:
        new_token = f"token_{uuid.uuid4().hex}"
        database.create_session(new_token, saved["mobile"], saved["id"])

    return UserProfile(**saved)

@router.put("/auth/crops", response_model=UserProfile)
@router.put("/crops/select", response_model=UserProfile)
def update_selected_crops(
    req: CropSelectionUpdateRequest,
    token: Optional[str] = Query(None),
    authorization: Optional[str] = Header(None),
    x_token: Optional[str] = Header(None)
):
    valid_crops = [c for c in req.selected_crops if c in ALLOWED_CROPS]
    if not valid_crops:
        valid_crops = ["Grapes", "Onion"]

    token_str = _extract_token(token, authorization, x_token)
    user = _resolve_user(token_str)

    updated = database.update_user_crops(user["mobile"], valid_crops)
    return UserProfile(**(updated or user))

@router.post("/auth/forgot-password")
def forgot_password(login: str = Query(..., description="Mobile number or email")):
    return {
        "status": "success",
        "message": f"Password reset instructions and OTP sent to {login}.",
        "verification_status": "DEMO"
    }
