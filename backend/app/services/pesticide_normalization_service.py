import os
import csv
import re
from typing import Dict, Optional, List, Any
from ..core.config import settings

class PesticideNormalizationService:
    def __init__(self):
        self.aliases_file = os.path.join(settings.DATA_DIR, "active_ingredient_aliases.csv")
        self.alias_map: Dict[str, str] = {}
        self._load_aliases()

    def _load_aliases(self):
        if os.path.exists(self.aliases_file):
            try:
                with open(self.aliases_file, mode="r", encoding="utf-8") as f:
                    reader = csv.DictReader(f)
                    for row in reader:
                        alias = row.get("alias", "").strip().lower()
                        canonical = row.get("canonical_name", "").strip()
                        if alias and canonical:
                            self.alias_map[alias] = canonical
            except Exception as e:
                pass

    def normalize_active_ingredient_name(self, raw_name: Optional[str]) -> str:
        """
        Cleans and normalizes raw active ingredient string to canonical scientific name.
        Removes percentages, formulation suffixes, and maps known abbreviations.
        """
        if not raw_name:
            return ""

        text = raw_name.strip()

        # Check direct lookup first
        lower_full = text.lower()
        if lower_full in self.alias_map:
            return self.alias_map[lower_full]

        # Strip percentages (e.g. 75%, 25.9 %, 50% wp)
        cleaned = re.sub(r'\b\d+(?:\.\d+)?\s*%', '', text, flags=re.IGNORECASE)
        # Strip trailing formulation codes
        cleaned = re.sub(r'\b(wp|ec|sc|sl|gr|fs|sg|sp|df|wsg)\b', '', cleaned, flags=re.IGNORECASE)
        # Strip trailing numbers like '50', '250', '75'
        cleaned = re.sub(r'\b\d+\b', '', cleaned)
        # Strip multiple spaces and punctuation
        cleaned = re.sub(r'[\+\/\,\-]', ' ', cleaned)
        cleaned = re.sub(r'\s+', ' ', cleaned).strip()

        lower_cleaned = cleaned.lower()
        if lower_cleaned in self.alias_map:
            return self.alias_map[lower_cleaned]

        # Word-by-word alias matching for compound chemicals (e.g. "metalaxyl mancozeb")
        words = lower_cleaned.split()
        normalized_words = [self.alias_map.get(w, w.capitalize()) for w in words]
        if normalized_words:
            candidate = " ".join(normalized_words)
            if candidate.lower() in self.alias_map:
                return self.alias_map[candidate.lower()]
            return candidate

        return text.title()

    def parse_composition_string(self, comp_str: str) -> List[Dict[str, Any]]:
        """
        Parses complex multi-ingredient composition strings such as:
        'Metalaxyl-M 4% + Mancozeb 64% WP' or 'Fluopyram 200 + Tebuconazole 200 SC'
        """
        results = []
        if not comp_str:
            return results

        parts = re.split(r'\+|\band\b|\&', comp_str, flags=re.IGNORECASE)
        for part in parts:
            part = part.strip()
            if not part:
                continue

            # Check pattern: Name + Number + Unit
            match = re.search(r'([A-Za-z\s\-]+?)\s*(\d+(?:\.\d+)?)\s*(%|g\/kg|g\/l|sc|ec|wp|sl)?', part, flags=re.IGNORECASE)
            if match:
                raw_name = match.group(1).strip()
                val_str = match.group(2)
                unit_str = match.group(3) or "%"

                norm_name = self.normalize_active_ingredient_name(raw_name)
                try:
                    val = float(val_str)
                except ValueError:
                    val = None

                results.append({
                    "name": norm_name,
                    "raw_name": raw_name,
                    "concentration": f"{val_str}{unit_str}",
                    "concentration_value": val,
                    "concentration_unit": unit_str,
                    "role": "fungicide"
                })
            else:
                norm_name = self.normalize_active_ingredient_name(part)
                results.append({
                    "name": norm_name,
                    "raw_name": part,
                    "concentration": None,
                    "concentration_value": None,
                    "concentration_unit": "%",
                    "role": "fungicide"
                })

        return results

pesticide_normalization_service = PesticideNormalizationService()
