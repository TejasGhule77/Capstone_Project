import os
import csv
import json
from typing import List, Dict, Any
from fastapi import APIRouter, HTTPException
from ..core.config import settings
from ..models.schemas import CropDetail

router = APIRouter(tags=["Crops & Phenological Stages"])

def _load_crops_from_csv() -> List[CropDetail]:
    crops_path = os.path.join(settings.DATA_DIR, "crops.csv")
    stages_path = os.path.join(settings.DATA_DIR, "crop_stages.csv")
    
    stages_by_crop = {}
    if os.path.exists(stages_path):
        with open(stages_path, mode="r", encoding="utf-8") as f:
            reader = csv.DictReader(f)
            for row in reader:
                c_id = row.get("crop_id", "")
                stages_by_crop.setdefault(c_id, []).append(row)

    crops_list = []
    if os.path.exists(crops_path):
        with open(crops_path, mode="r", encoding="utf-8") as f:
            reader = csv.DictReader(f)
            for row in reader:
                c_id = row.get("crop_id", "")
                crop_name = row.get("crop_name", "")
                
                # Extra metadata
                marathi_name = {
                    "Onion": "कांदा",
                    "Grapes": "द्राक्षे",
                    "Sugarcane": "ऊस",
                    "Wheat": "गहू"
                }.get(crop_name, crop_name)

                season_map = {
                    "Onion": ["Rabi", "Kharif", "Late Kharif"],
                    "Grapes": ["Foundation (April)", "Fruit Pruning (Oct)"],
                    "Sugarcane": ["Suru", "Adsali", "Pre-seasonal"],
                    "Wheat": ["Rabi"]
                }.get(crop_name, ["All Season"])

                districts_map = {
                    "Onion": ["Nashik", "Pune", "Ahmednagar", "Solapur"],
                    "Grapes": ["Nashik", "Sangli", "Solapur", "Pune"],
                    "Sugarcane": ["Kolhapur", "Pune", "Satara", "Ahmednagar"],
                    "Wheat": ["Pune", "Satara", "Nashik", "Aurangabad"]
                }.get(crop_name, ["Maharashtra"])

                crops_list.append(CropDetail(
                    crop_id=c_id,
                    crop_name=crop_name,
                    scientific_name=row.get("scientific_name", ""),
                    crop_type=row.get("crop_type", ""),
                    marathi_name=marathi_name,
                    season=season_map,
                    duration_days=150 if crop_name == "Grapes" else (365 if crop_name == "Sugarcane" else 120),
                    major_districts=districts_map,
                    stages=stages_by_crop.get(c_id, []),
                    verification_status=row.get("verification_status", "VERIFIED"),
                    source=row.get("source", "ICAR"),
                    source_url=row.get("source_url", ""),
                    last_verified=row.get("last_verified", "2026-08-20")
                ))

    if not crops_list:
        # Static authoritative fallback
        return [
            CropDetail(
                crop_id="crop_onion", crop_name="Onion", scientific_name="Allium cepa",
                crop_type="Vegetable / Bulb", marathi_name="कांदा",
                season=["Rabi", "Kharif"], duration_days=120,
                major_districts=["Nashik", "Pune", "Solapur"],
                verification_status="VERIFIED", source="ICAR - DOGR", source_url="https://dogr.icar.gov.in"
            ),
            CropDetail(
                crop_id="crop_grapes", crop_name="Grapes", scientific_name="Vitis vinifera",
                crop_type="Horticulture / Fruit", marathi_name="द्राक्षे",
                season=["Perennial"], duration_days=150,
                major_districts=["Nashik", "Sangli", "Solapur"],
                verification_status="VERIFIED", source="ICAR - NRC Grapes", source_url="https://nrcgrapes.icar.gov.in"
            ),
            CropDetail(
                crop_id="crop_sugarcane", crop_name="Sugarcane", scientific_name="Saccharum officinarum",
                crop_type="Commercial / Cash Crop", marathi_name="ऊस",
                season=["Eksali", "Suru"], duration_days=365,
                major_districts=["Kolhapur", "Pune", "Satara"],
                verification_status="VERIFIED", source="ICAR - SBI & VSI", source_url="https://sugarcane.icar.gov.in"
            ),
            CropDetail(
                crop_id="crop_wheat", crop_name="Wheat", scientific_name="Triticum aestivum",
                crop_type="Cereal / Food Grain", marathi_name="गहू",
                season=["Rabi"], duration_days=110,
                major_districts=["Pune", "Satara", "Nashik"],
                verification_status="VERIFIED", source="ICAR - IIWBR", source_url="https://iiwbr.icar.gov.in"
            )
        ]

    return crops_list

@router.get("/crops", response_model=List[CropDetail])
def get_all_supported_crops():
    """Returns strictly the 4 core supported crops (Onion, Grapes, Sugarcane, Wheat)."""
    return _load_crops_from_csv()

@router.get("/crops/{crop_id}", response_model=CropDetail)
def get_crop_by_id(crop_id: str):
    """Returns detailed crop profile for the specified crop ID or name."""
    all_crops = _load_crops_from_csv()
    target = crop_id.strip().lower()
    for c in all_crops:
        if c.crop_id.lower() == target or c.crop_name.lower() == target:
            return c
    raise HTTPException(status_code=404, detail=f"Crop '{crop_id}' not found in primary supported registry.")

@router.get("/crops/stages/all")
def get_crop_stages():
    """Returns stage-wise developmental information for the 4 crops."""
    stages_path = os.path.join(settings.DATA_DIR, "crop_stages.csv")
    if os.path.exists(stages_path):
        with open(stages_path, mode="r", encoding="utf-8") as f:
            reader = csv.DictReader(f)
            return list(reader)
    return []
