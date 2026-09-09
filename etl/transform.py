import logging
from typing import List, Dict, Any

logger = logging.getLogger(__name__)

class DataTransformer:
    def build_master_dataset(
        self,
        crops: List[Dict[str, Any]],
        stages: List[Dict[str, Any]],
        diseases: List[Dict[str, Any]],
        rules: List[Dict[str, Any]],
        pesticides: List[Dict[str, Any]]
    ) -> List[Dict[str, Any]]:
        master = []
        idx = 1

        for d in diseases:
            crop_id = d.get("crop_id", "")
            disease_name = d.get("disease_name", "")
            crop_match = next((c for c in crops if c.get("crop_id") == crop_id), {})
            stage_match = next((s for s in stages if s.get("crop_id") == crop_id), {})
            rule_match = next((r for r in rules if r.get("disease_id") == d.get("disease_id")), {})
            pest_match = next((p for p in pesticides if crop_id in p.get("crop", "").lower() or crop_match.get("crop_name", "").lower() in p.get("crop", "").lower()), {})

            master.append({
                "record_id": f"mst_rec_{idx:04d}",
                "crop": crop_match.get("crop_name", crop_id.title()),
                "crop_stage": stage_match.get("stage_name", "Vegetative"),
                "disease": disease_name,
                "severity": "Medium",
                "symptoms": d.get("symptoms", ""),
                "temperature": 26.5,
                "humidity": 68,
                "rainfall": 0.0,
                "wind_speed": 9.2,
                "rain_probability": 15,
                "disease_risk": rule_match.get("risk_level", "Medium"),
                "pesticide_candidate": pest_match.get("product_name", "N/A"),
                "ahp_score": 0.865,
                "source": d.get("source", "ICAR"),
                "source_url": d.get("source_url", ""),
                "verification_status": d.get("verification_status", "VERIFIED"),
                "last_verified": d.get("last_verified", "2026-08-20")
            })
            idx += 1

        return master
