import logging
from typing import List, Dict, Any, Tuple

logger = logging.getLogger(__name__)

SUPPORTED_CROPS = {
    "onion", "grapes", "sugarcane", "wheat",
    "crop_onion", "crop_grapes", "crop_sugarcane", "crop_wheat"
}
VALID_STATUSES = {"VERIFIED", "DEMO", "PENDING_REVIEW", "EXPIRED"}

class DataValidator:
    def validate_crop_records(self, records: List[Dict[str, Any]]) -> Tuple[List[Dict[str, Any]], List[Dict[str, Any]]]:
        valid, rejected = [], []
        seen_ids = set()

        for rec in records:
            crop_id = str(rec.get("crop_id", "")).strip().lower()
            crop_name = str(rec.get("crop_name", "")).strip().lower()

            if not crop_id or (crop_id not in SUPPORTED_CROPS and crop_name not in SUPPORTED_CROPS):
                logger.warning(f"Rejected crop record with invalid crop_id/crop_name: {crop_id}/{crop_name}")
                rejected.append(rec)
                continue
            
            if crop_id in seen_ids:
                logger.warning(f"Rejected duplicate crop_id: {crop_id}")
                rejected.append(rec)
                continue

            status = rec.get("verification_status", "PENDING_REVIEW")
            if status not in VALID_STATUSES:
                rec["verification_status"] = "PENDING_REVIEW"

            seen_ids.add(crop_id)
            valid.append(rec)

        return valid, rejected

    def validate_disease_records(self, records: List[Dict[str, Any]]) -> Tuple[List[Dict[str, Any]], List[Dict[str, Any]]]:
        valid, rejected = [], []
        seen_ids = set()

        for rec in records:
            d_id = str(rec.get("disease_id", "")).strip()
            crop_id = str(rec.get("crop_id", "")).strip().lower()

            if not d_id or crop_id not in SUPPORTED_CROPS:
                logger.warning(f"Rejected disease record: {d_id} with crop_id: {crop_id}")
                rejected.append(rec)
                continue

            if d_id in seen_ids:
                logger.warning(f"Rejected duplicate disease_id: {d_id}")
                rejected.append(rec)
                continue

            status = rec.get("verification_status", "PENDING_REVIEW")
            if status not in VALID_STATUSES:
                rec["verification_status"] = "PENDING_REVIEW"

            seen_ids.add(d_id)
            valid.append(rec)

        return valid, rejected

    def validate_pesticide_records(self, records: List[Dict[str, Any]]) -> Tuple[List[Dict[str, Any]], List[Dict[str, Any]]]:
        valid, rejected = [], []
        seen_ids = set()

        for rec in records:
            p_id = str(rec.get("pesticide_id", "")).strip()
            crop = str(rec.get("crop", "")).strip().lower()

            if not p_id or not any(c in crop for c in ["onion", "grape", "sugarcane", "wheat"]):
                logger.warning(f"Rejected pesticide record: {p_id} for unsupported crop: {crop}")
                rejected.append(rec)
                continue

            if p_id in seen_ids:
                logger.warning(f"Rejected duplicate pesticide_id: {p_id}")
                rejected.append(rec)
                continue

            status = rec.get("verification_status", "PENDING_REVIEW")
            if status not in VALID_STATUSES:
                rec["verification_status"] = "PENDING_REVIEW"

            seen_ids.add(p_id)
            valid.append(rec)

        return valid, rejected
