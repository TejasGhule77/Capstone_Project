import os
import csv
import json
from typing import List, Optional
from fastapi import APIRouter, Query
from ..core.config import settings
from ..models.schemas import AdvisoryItem, PesticideItem

router = APIRouter(tags=["Advisories & Verified Pesticides"])

@router.get("/advisories", response_model=List[AdvisoryItem])
@router.get("/advisory", response_model=List[AdvisoryItem])
def get_advisories(crop: Optional[str] = Query(None, description="Optional filter by crop name")):
    """Returns stage-wise agronomy advisories and agromet alerts."""
    advisories_path = os.path.join(settings.DATA_DEMO_DIR, "advisories.json")
    if os.path.exists(advisories_path):
        with open(advisories_path, "r", encoding="utf-8") as f:
            items = json.load(f)
            if crop:
                items = [
                    i for i in items
                    if i.get("crop_name", "").lower() == crop.lower()
                    or i.get("crop_id", "").lower() == crop.lower()
                    or crop.lower() in i.get("crop_name", "").lower()
                ]
            return [AdvisoryItem(**i) for i in items]

    # In-memory fallback
    items = [
        AdvisoryItem(
            id="adv_001",
            crop_name="Grapes",
            stage="Shooting & Flowering",
            alert_type="WARNING",
            title="Downy Mildew & Berry Thinning Protocols",
            summary="Recent cloud cover raises humidity above 75%. Protect inflorescence clusters.",
            actionPoints=[
                "Apply Potassium Phosphonate @ 3g/L for systemic oomycete protection.",
                "Perform manual cluster tipping to ensure uniform berry elongation.",
                "Ensure morning spray window before 11:00 AM."
            ],
            weather_gatekeeper_status="GOOD_TO_SPRAY",
            ahp_score=0.94,
            blockchain_proof="sha256:7c992d551bfa3ca3ee45812d6fee2ca014856f690226346addd1c60144c10f5f",
            verification_status="DEMO"
        ),
        AdvisoryItem(
            id="adv_002",
            crop_name="Onion",
            stage="Bulb Initiation",
            alert_type="URGENT",
            title="Purple Blotch Prophylactic Advisory",
            summary="High morning dew and moderate daytime temperature favor purple blotch.",
            actionPoints=[
                "Spray Mancozeb 75% WP @ 2.5g/L or Tebuconazole @ 1ml/L.",
                "Add sticker/spreader agent (0.5ml/L) due to waxy foliage."
            ],
            weather_gatekeeper_status="GOOD_TO_SPRAY",
            ahp_score=0.88,
            blockchain_proof="sha256:4b227777d4da1fc151ee0f6564e9a3d6990264e718e80e6c7dc356b3e41459a7",
            verification_status="DEMO"
        )
    ]
    if crop:
        items = [i for i in items if crop.lower() in i.crop_name.lower()]
    return items

@router.get("/pesticides", response_model=List[PesticideItem])
def get_verified_pesticides(crop: Optional[str] = Query(None, description="Optional filter by crop name")):
    """Returns verified pesticide entries with CIB&RC and ICAR registration metadata."""
    pest_path = os.path.join(settings.DATA_DIR, "pesticides.csv")
    results = []
    if os.path.exists(pest_path):
        with open(pest_path, mode="r", encoding="utf-8") as f:
            reader = csv.DictReader(f)
            for row in reader:
                if crop and crop.lower() not in row.get("crop", "").lower():
                    continue
                results.append(PesticideItem(**row))
    return results
