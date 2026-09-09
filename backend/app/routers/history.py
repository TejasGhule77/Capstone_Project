import time
from typing import List, Optional
from fastapi import APIRouter, Query
from ..models.schemas import HistoryRecord

router = APIRouter(tags=["Farmer History & Activity Log"])

@router.get("/history", response_model=List[HistoryRecord])
def get_user_history(
    user_id: Optional[str] = Query("usr_demo_001", description="Farmer User ID"),
    crop: Optional[str] = Query(None, description="Optional filter by crop")
):
    """Returns chronologically ordered farmer advisory, diagnosis, and recommendation history."""
    records = [
        HistoryRecord(
            record_id="hist_001",
            user_id=user_id or "usr_demo_001",
            crop="Grapes",
            type="DIAGNOSIS",
            title="Downy Mildew Leaf Scan",
            details={
                "disease": "Downy Mildew",
                "severity": "Medium",
                "confidence": 0.965,
                "weather_status": "GOOD_TO_SPRAY",
                "recommendation": "Potassium Phosphonate @ 3g/L"
            },
            blockchain_hash="7c992d551bfa3ca3ee45812d6fee2ca014856f690226346addd1c60144c10f5f",
            timestamp="2026-09-08T09:30:00Z",
            verification_status="DEMO"
        ),
        HistoryRecord(
            record_id="hist_002",
            user_id=user_id or "usr_demo_001",
            crop="Onion",
            type="RECOMMENDATION",
            title="Purple Blotch AHP Pesticide Selection",
            details={
                "top_candidate": "Mancozeb 75% WP",
                "ahp_score": 0.915,
                "phi": "7 Days",
                "gatekeeper": "GOOD_TO_SPRAY"
            },
            blockchain_hash="4b227777d4da1fc151ee0f6564e9a3d6990264e718e80e6c7dc356b3e41459a7",
            timestamp="2026-09-07T14:15:00Z",
            verification_status="DEMO"
        ),
        HistoryRecord(
            record_id="hist_003",
            user_id=user_id or "usr_demo_001",
            crop="Grapes",
            type="SPRAY_LOG",
            title="Pre-flowering Prophylactic Spray",
            details={
                "product": "K-Phite (Potassium Phosphonate)",
                "dosage": "3.0 g/L",
                "tank_volume_liters": 200,
                "wind_speed_kmh": 6.5
            },
            blockchain_hash="e88457223f66c98aa2b3112a550d52481023a411ecba332b77051cc572881290",
            timestamp="2026-09-05T07:00:00Z",
            verification_status="DEMO"
        )
    ]

    if crop:
        records = [r for r in records if r.crop.lower() == crop.lower()]

    return records
