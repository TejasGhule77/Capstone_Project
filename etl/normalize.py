from typing import List, Dict, Any

class DataNormalizer:
    @staticmethod
    def normalize_string(text: str) -> str:
        return " ".join(str(text).strip().split()) if text else ""

    @staticmethod
    def normalize_crop_name(name: str) -> str:
        name_clean = name.strip().title()
        mapping = {
            "Onion": "Onion",
            "Grapes": "Grapes",
            "Grape": "Grapes",
            "Sugarcane": "Sugarcane",
            "Wheat": "Wheat"
        }
        return mapping.get(name_clean, name_clean)
