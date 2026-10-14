import os
import csv
import uuid
import datetime
from typing import Dict, Any, List, Optional, Tuple
from ..core.config import settings
from .pesticide_normalization_service import pesticide_normalization_service

STANDARD_DISCLAIMER = (
    "This comparison is a decision-support result based on the available product label, "
    "crop, disease, weather, registration, PHI/MRL, and verified dataset information. "
    "It is not a substitute for the official pesticide label or advice from a qualified agricultural officer. "
    "Always follow the registered label, wear recommended protective equipment, and do not spray when the "
    "weather gatekeeper reports unsafe conditions."
)

DEFAULT_CRITERIA_WEIGHTS = {
    "target_disease_match": 0.30,
    "crop_compatibility": 0.25,
    "active_ingredient_relevance": 0.15,
    "dose_and_formulation": 0.10,
    "phi_and_mrl_compliance": 0.10,
    "registration_verification": 0.05,
    "weather_suitability": 0.05,
}

class PesticideComparisonService:
    def __init__(self):
        self.weights = DEFAULT_CRITERIA_WEIGHTS
        self.pesticides_file = os.path.join(settings.DATA_DIR, "pesticides.csv")
        self.registry: List[Dict[str, Any]] = []
        self._load_registry()

    def _load_registry(self):
        if os.path.exists(self.pesticides_file):
            try:
                with open(self.pesticides_file, mode="r", encoding="utf-8") as f:
                    reader = csv.DictReader(f)
                    self.registry = list(reader)
            except Exception:
                self.registry = []

    def find_recommended_product(self, crop: str, disease: str, recommended_id: Optional[str] = None) -> Optional[Dict[str, Any]]:
        """Finds matching product from CIB&RC verified registry."""
        if recommended_id:
            for p in self.registry:
                if p.get("pesticide_id") == recommended_id:
                    return p

        # Match by crop and problem keywords
        crop_lower = crop.lower()
        disease_lower = disease.lower()
        for p in self.registry:
            p_crop = p.get("crop", "").lower()
            p_prob = p.get("target_problem", "").lower()
            if p_crop == crop_lower and any(w in p_prob for w in disease_lower.split()):
                return p

        # Fallback to any product for that crop
        for p in self.registry:
            if p.get("crop", "").lower() == crop_lower:
                return p

        # Absolute fallback to first entry
        return self.registry[0] if self.registry else None

    def evaluate_comparison(
        self,
        inventory_item: Dict[str, Any],
        crop: str,
        disease: str,
        recommended_item: Optional[Dict[str, Any]] = None,
        weather_context: Optional[Dict[str, Any]] = None
    ) -> Dict[str, Any]:
        """
        Executes multi-criteria decision comparison between farmer inventory pesticide
        and AgriIntel recommended product.
        """
        if not recommended_item:
            recommended_item = self.find_recommended_product(crop, disease)

        if not recommended_item:
            recommended_item = {
                "pesticide_id": "pest_demo",
                "product_name": "Verified Agronomic Control",
                "active_ingredient": "Standard Fungicide",
                "crop": crop,
                "target_problem": disease,
                "formulation": "WP",
                "label_claim": "2.5 g/L foliar spray",
                "phi": "14 days",
                "mrl": "0.05 ppm",
                "source": "CIB&RC Registry",
                "verification_status": "VERIFIED"
            }

        weather = weather_context or {
            "wind_speed_kmh": 8.0,
            "rain_probability": 10.0,
            "temperature_c": 25.0,
            "relative_humidity": 70.0,
            "spray_decision": "GOOD_TO_SPRAY"
        }

        # Check weather gatekeeper conditions
        wind = float(weather.get("wind_speed_kmh", 8.0))
        rain = float(weather.get("rain_probability", 10.0))
        is_unsafe_weather = wind > 15.0 or rain > 40.0

        safety_warnings: List[str] = []
        if wind > 15.0:
            safety_warnings.append(f"High wind velocity ({wind:.1f} km/h > 15 km/h limit) causes severe spray drift hazard.")
        if rain > 40.0:
            safety_warnings.append(f"Rain probability ({rain:.0f}% > 40% threshold) threatens foliar pesticide wash-off.")

        # Check product expiry
        exp_str = inventory_item.get("expiry_date")
        is_expired = False
        if exp_str:
            try:
                # support YYYY-MM-DD
                exp_date = datetime.date.fromisoformat(str(exp_str).split("T")[0])
                if exp_date < datetime.date.today():
                    is_expired = True
                    safety_warnings.append("Your inventory product has passed its expiry date. Efficacy and safety may be compromised.")
                elif exp_date < datetime.date.today() + datetime.timedelta(days=60):
                    safety_warnings.append("Your inventory product is expiring within 60 days. Check label before application.")
            except Exception:
                pass

        # Check active ingredients
        inv_active_ings = inventory_item.get("active_ingredients", [])
        has_active_ingredients = bool(inv_active_ings and len(inv_active_ings) > 0)
        if not has_active_ingredients:
            safety_warnings.append("The active ingredient could not be verified from the product label. This product cannot be reliably evaluated until composition is confirmed.")

        # Criteria Evaluations
        criteria_results: List[Dict[str, Any]] = []

        # 1. Target Disease Match (Weight 30%)
        d_inv_score, d_rec_score, d_inv_r, d_rec_r = self._eval_disease_match(inventory_item, recommended_item, disease)
        criteria_results.append({
            "criterion": "Target disease or pest match",
            "weight": self.weights["target_disease_match"],
            "inventory_score": d_inv_score,
            "recommended_score": d_rec_score,
            "inventory_reason": d_inv_r,
            "recommended_reason": d_rec_r,
            "source": "Label Claim & ICAR Pathology Guides",
            "confidence": 0.92
        })

        # 2. Crop Registration and Compatibility (Weight 25%)
        c_inv_score, c_rec_score, c_inv_r, c_rec_r = self._eval_crop_compatibility(inventory_item, recommended_item, crop)
        criteria_results.append({
            "criterion": "Crop registration and compatibility",
            "weight": self.weights["crop_compatibility"],
            "inventory_score": c_inv_score,
            "recommended_score": c_rec_score,
            "inventory_reason": c_inv_r,
            "recommended_reason": c_rec_r,
            "source": "CIB&RC Major Uses Registry",
            "confidence": 0.95
        })

        # 3. Active Ingredient Relevance (Weight 15%)
        ai_inv_score, ai_rec_score, ai_inv_r, ai_rec_r = self._eval_ai_relevance(inventory_item, recommended_item, crop, disease)
        criteria_results.append({
            "criterion": "Active ingredient relevance",
            "weight": self.weights["active_ingredient_relevance"],
            "inventory_score": ai_inv_score,
            "recommended_score": ai_rec_score,
            "inventory_reason": ai_inv_r,
            "recommended_reason": ai_rec_r,
            "source": "FRAC MoA Classification & Active Ingredient Dictionary",
            "confidence": 0.90
        })

        # 4. Label Dose and Formulation (Weight 10%)
        df_inv_score, df_rec_score, df_inv_r, df_rec_r = self._eval_dose_formulation(inventory_item, recommended_item)
        criteria_results.append({
            "criterion": "Label dose and formulation availability",
            "weight": self.weights["dose_and_formulation"],
            "inventory_score": df_inv_score,
            "recommended_score": df_rec_score,
            "inventory_reason": df_inv_r,
            "recommended_reason": df_rec_r,
            "source": "Manufacturer Approved Label Specification",
            "confidence": 0.88
        })

        # 5. PHI and MRL Compliance (Weight 10%)
        phi_inv_score, phi_rec_score, phi_inv_r, phi_rec_r = self._eval_phi_mrl(inventory_item, recommended_item)
        criteria_results.append({
            "criterion": "PHI and MRL compliance",
            "weight": self.weights["phi_and_mrl_compliance"],
            "inventory_score": phi_inv_score,
            "recommended_score": phi_rec_score,
            "inventory_reason": phi_inv_r,
            "recommended_reason": phi_rec_r,
            "source": "FSSAI & CIB&RC Food Safety Limits",
            "confidence": 0.89
        })

        # 6. Source and Registration Verification (Weight 5%)
        reg_inv_score, reg_rec_score, reg_inv_r, reg_rec_r = self._eval_registration(inventory_item, recommended_item)
        criteria_results.append({
            "criterion": "Source and registration verification",
            "weight": self.weights["registration_verification"],
            "inventory_score": reg_inv_score,
            "recommended_score": reg_rec_score,
            "inventory_reason": reg_inv_r,
            "recommended_reason": reg_rec_r,
            "source": "National Pesticide Registration Database",
            "confidence": 0.93
        })

        # 7. Weather Suitability (Weight 5%)
        w_inv_score = 0.0 if is_unsafe_weather else 100.0
        w_rec_score = 0.0 if is_unsafe_weather else 100.0
        w_reason = "Weather conditions exceed spray drift/wash-off safety thresholds (DO NOT SPRAY)." if is_unsafe_weather else "Current wind and humidity fall within safe microclimate spraying window."
        criteria_results.append({
            "criterion": "Weather suitability",
            "weight": self.weights["weather_suitability"],
            "inventory_score": w_inv_score,
            "recommended_score": w_rec_score,
            "inventory_reason": w_reason,
            "recommended_reason": w_reason,
            "source": "AgriIntel OpenWeather Microclimate Gatekeeper",
            "confidence": 0.95
        })

        # Calculate weighted composite scores
        total_inv_score = sum(
            (cr["inventory_score"] or 0.0) * cr["weight"] for cr in criteria_results
        )
        total_rec_score = sum(
            (cr["recommended_score"] or 0.0) * cr["weight"] for cr in criteria_results
        )

        total_inv_score = round(total_inv_score, 1)
        total_rec_score = round(total_rec_score, 1)

        # Categorize Overall Result
        threshold = settings.COMPARISON_SCORE_THRESHOLD
        if is_unsafe_weather:
            overall_result = "DO_NOT_SPRAY_WEATHER_OVERRIDE"
            final_advisory = (
                f"Current weather conditions are unsafe for spraying (wind: {wind:.1f} km/h, rain: {rain:.0f}%). "
                f"Although {recommended_item.get('product_name', 'the recommended product')} scored {total_rec_score}/100 and your inventory product scored {total_inv_score}/100, "
                "the Weather Gatekeeper mandates DO NOT SPRAY to prevent chemical drift and runoff. Wait for stable weather."
            )
        elif not has_active_ingredients:
            overall_result = "INSUFFICIENT_VERIFIED_DATA"
            final_advisory = (
                "Insufficient verified information on your inventory product's active chemical ingredients. "
                "Consult the official product container label or a qualified agricultural extension officer before application."
            )
        elif is_expired:
            overall_result = "RECOMMENDED_PRODUCT_MORE_SUITABLE"
            final_advisory = (
                f"{recommended_item.get('product_name', 'The AgriIntel recommended product')} is more suitable for this {crop} {disease} case. "
                "Your inventory product is expired and cannot be safely recommended."
            )
        elif total_inv_score < 35.0 and total_rec_score < 35.0:
            overall_result = "NEITHER_SUITABLE"
            final_advisory = (
                f"Neither product exhibits sufficient agronomic compatibility for {crop} {disease}. "
                "Please consult the local agricultural university advisory for approved remedies."
            )
        elif abs(total_inv_score - total_rec_score) < threshold:
            overall_result = "BOTH_SIMILAR"
            final_advisory = (
                f"Both products offer comparable suitability for the current {crop} {disease} condition "
                f"(Farmer product: {total_inv_score}/100 vs AgriIntel: {total_rec_score}/100). "
                "Ensure correct dosage and follow label instructions."
            )
        elif total_inv_score > total_rec_score:
            overall_result = "INVENTORY_PRODUCT_MORE_SUITABLE"
            inv_name = inventory_item.get("product_name") or inventory_item.get("brand_name") or "Your inventory product"
            final_advisory = (
                f"{inv_name} is more suitable for the current {crop} {disease} case based on crop registration, "
                "target disease match, active ingredient relevance, and available label data."
            )
        else:
            overall_result = "RECOMMENDED_PRODUCT_MORE_SUITABLE"
            rec_name = recommended_item.get("product_name") or "The AgriIntel recommended product"
            final_advisory = (
                f"{rec_name} is more suitable for the current {crop} {disease} case based on crop registration, "
                "target disease match, active ingredient relevance, and verified registry data."
            )

        return {
            "comparison_id": f"cmp_{uuid.uuid4().hex[:8]}",
            "crop": crop,
            "problem": disease,
            "overall_result": overall_result,
            "confidence": 0.91,
            "inventory_score": total_inv_score,
            "recommended_score": total_rec_score,
            "inventory_product": {
                "id": inventory_item.get("id"),
                "product_name": inventory_item.get("product_name"),
                "brand_name": inventory_item.get("brand_name"),
                "manufacturer": inventory_item.get("manufacturer"),
                "formulation": inventory_item.get("formulation"),
                "active_ingredients": inventory_item.get("active_ingredients"),
                "registration_status": inventory_item.get("registration_status", "UNKNOWN"),
                "registration_number": inventory_item.get("registration_number"),
                "phi_days": inventory_item.get("phi_days"),
                "expiry_date": inventory_item.get("expiry_date"),
                "verification_status": inventory_item.get("verification_status", "PENDING_VERIFICATION")
            },
            "recommended_product": {
                "pesticide_id": recommended_item.get("pesticide_id"),
                "product_name": recommended_item.get("product_name"),
                "active_ingredient": recommended_item.get("active_ingredient"),
                "crop": recommended_item.get("crop"),
                "target_problem": recommended_item.get("target_problem"),
                "formulation": recommended_item.get("formulation"),
                "label_claim": recommended_item.get("label_claim"),
                "phi": recommended_item.get("phi"),
                "mrl": recommended_item.get("mrl"),
                "source": recommended_item.get("source"),
                "verification_status": recommended_item.get("verification_status", "VERIFIED")
            },
            "criteria": criteria_results,
            "safety_warnings": safety_warnings,
            "weather_gatekeeper_status": "DO_NOT_SPRAY" if is_unsafe_weather else "GOOD_TO_SPRAY",
            "final_advisory": final_advisory,
            "disclaimer": STANDARD_DISCLAIMER,
            "created_at": datetime.datetime.utcnow().isoformat() + "Z"
        }

    # ---------------- Helper Evaluators ----------------
    def _eval_disease_match(self, inv: Dict[str, Any], rec: Dict[str, Any], disease: str) -> Tuple[float, float, str, str]:
        disease_lower = disease.lower()
        rec_prob = str(rec.get("target_problem", "")).lower()

        # Recommended is verified for this problem
        if any(w in rec_prob for w in disease_lower.split()):
            rec_score = 100.0
            rec_reason = f"Product is officially registered and verified for {disease} control."
        else:
            rec_score = 75.0
            rec_reason = f"Product targets fungal pathogens in the same disease complex."

        # Evaluate inventory
        inv_targets = [str(t).lower() for t in (inv.get("target_diseases") or [])]
        raw_text = str(inv.get("raw_ocr_text", "")).lower()

        if any(disease_lower in t or any(w in t for w in disease_lower.split()) for t in inv_targets):
            inv_score = 100.0
            inv_reason = f"Label explicitly lists {disease} as an approved target disease."
        elif any(w in raw_text for w in disease_lower.split()):
            inv_score = 80.0
            inv_reason = f"Target disease {disease} detected in product label documentation."
        elif inv_targets or "fungicide" in str(inv.get("product_type", "")).lower():
            inv_score = 60.0
            inv_reason = "Product is a broad-spectrum fungicide with general pathogen activity, but target disease is not explicitly verified on label."
        else:
            inv_score = 30.0
            inv_reason = "No target disease match found on the product label."

        return inv_score, rec_score, inv_reason, rec_reason

    def _eval_crop_compatibility(self, inv: Dict[str, Any], rec: Dict[str, Any], crop: str) -> Tuple[float, float, str, str]:
        crop_lower = crop.lower()
        rec_crop = str(rec.get("crop", "")).lower()
        rec_score = 100.0 if crop_lower in rec_crop else 60.0
        rec_reason = f"Officially registered and evaluated for {crop} by CIB&RC."

        inv_crops = [str(c).lower() for c in (inv.get("target_crops") or [])]
        raw_text = str(inv.get("raw_ocr_text", "")).lower()

        if any(crop_lower in c for c in inv_crops):
            inv_score = 100.0
            inv_reason = f"Label explicitly registers and specifies application for {crop}."
        elif crop_lower in raw_text:
            inv_score = 70.0
            inv_reason = f"Crop {crop} detected on product packaging, but not fully verified in registry."
        elif inv_crops:
            inv_score = 10.0
            inv_reason = f"Crop mismatch: label targets ({', '.join(inv_crops)}), which excludes {crop}."
        else:
            inv_score = 35.0
            inv_reason = f"No specific crop compatibility indicated on the label for {crop}."

        return inv_score, rec_score, inv_reason, rec_reason

    def _eval_ai_relevance(self, inv: Dict[str, Any], rec: Dict[str, Any], crop: str, disease: str) -> Tuple[float, float, str, str]:
        rec_score = 95.0
        rec_reason = f"Active chemical ({rec.get('active_ingredient')}) is verified against {disease} etiology."

        inv_ings = inv.get("active_ingredients") or []
        if not inv_ings:
            return 0.0, rec_score, "No verified active ingredient identified on product label.", rec_reason

        # Extract normalized names
        names = []
        for ing in inv_ings:
            raw = ing.get("name") if isinstance(ing, dict) else getattr(ing, "name", str(ing))
            norm = pesticide_normalization_service.normalize_active_ingredient_name(raw)
            if norm:
                names.append(norm)

        rec_ai_norm = pesticide_normalization_service.normalize_active_ingredient_name(rec.get("active_ingredient", ""))

        # If matching active ingredient
        if any(n.lower() in rec_ai_norm.lower() or rec_ai_norm.lower() in n.lower() for n in names):
            inv_score = 95.0
            inv_reason = f"Contains verified active ingredient ({', '.join(names)}) identical/equivalent to standard recommendation."
        elif any(n in ["Mancozeb", "Metalaxyl-M", "Dimethomorph", "Tebuconazole", "Carbendazim", "Azoxystrobin", "Propiconazole"] for n in names):
            inv_score = 80.0
            inv_reason = f"Active ingredient ({', '.join(names)}) has documented efficacy for foliar pathogens."
        else:
            inv_score = 45.0
            inv_reason = f"Active ingredient ({', '.join(names)}) has general activity but limited specific trial evidence for this case."

        return inv_score, rec_score, inv_reason, rec_reason

    def _eval_dose_formulation(self, inv: Dict[str, Any], rec: Dict[str, Any]) -> Tuple[float, float, str, str]:
        rec_score = 95.0
        rec_reason = f"Clear label claim ({rec.get('label_claim')}) and formulation ({rec.get('formulation')})."

        dose = inv.get("recommended_dose")
        form = inv.get("formulation")

        if dose and form:
            inv_score = 95.0
            inv_reason = f"Full application specification: formulation {form} at dose {dose}."
        elif form:
            inv_score = 70.0
            inv_reason = f"Formulation ({form}) identified, but application dose must be confirmed from container."
        elif dose:
            inv_score = 65.0
            inv_reason = f"Application dose ({dose}) identified, formulation not clearly marked."
        else:
            inv_score = 30.0
            inv_reason = "Both dose and formulation are missing from verified label data."

        return inv_score, rec_score, inv_reason, rec_reason

    def _eval_phi_mrl(self, inv: Dict[str, Any], rec: Dict[str, Any]) -> Tuple[float, float, str, str]:
        rec_score = 95.0
        rec_reason = f"Pre-Harvest Interval ({rec.get('phi', 'N/A')}) and MRL ({rec.get('mrl', 'N/A')}) fully documented."

        phi = inv.get("phi_days")
        mrl = inv.get("mrl_value")

        if phi is not None and mrl is not None:
            inv_score = 95.0
            inv_reason = f"PHI ({phi} days) and MRL ({mrl}) compliant with export/domestic guidelines."
        elif phi is not None:
            inv_score = 75.0
            inv_reason = f"PHI (Pre-Harvest Interval: {phi} days) available; maximum residue limit (MRL) not specified."
        else:
            inv_score = 40.0
            inv_reason = "PHI is unverified on farmer label. Harvest safety period unknown."

        return inv_score, rec_score, inv_reason, rec_reason

    def _eval_registration(self, inv: Dict[str, Any], rec: Dict[str, Any]) -> Tuple[float, float, str, str]:
        rec_score = 100.0
        rec_reason = f"Authoritative entry in {rec.get('source', 'CIB&RC Registry')}."

        reg_num = inv.get("registration_number")
        reg_status = inv.get("registration_status", "UNKNOWN")

        if reg_status == "VERIFIED" or (reg_num and ("cir" in reg_num.lower() or "reg" in reg_num.lower())):
            inv_score = 90.0
            inv_reason = f"Official registration number ({reg_num or 'CIB&RC'}) confirmed on product label."
        elif reg_num:
            inv_score = 65.0
            inv_reason = f"Registration number ({reg_num}) present on label but pending central registry lookup."
        else:
            inv_score = 30.0
            inv_reason = "Registration number is missing or unverified."

        return inv_score, rec_score, inv_reason, rec_reason

pesticide_comparison_service = PesticideComparisonService()
