import sys
import os
import pytest

sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "..")))

from fastapi.testclient import TestClient
from backend.app.main import app

client = TestClient(app)

@pytest.fixture(scope="module")
def setup_inventory_items():
    headers = {"Authorization": "Bearer demo_token_secret_123"}
    # 1. Compatible Grape Downy Mildew Fungicide
    res1 = client.post("/api/inventory/pesticides", json={
        "product_name": "Farmer Dimethomorph 50 WP",
        "brand_name": "Acrobat Generic",
        "formulation": "WP",
        "registration_number": "CIR-8890/2021",
        "active_ingredients": [{"name": "Dimethomorph", "concentration": "50%", "concentration_value": 50.0, "concentration_unit": "%"}],
        "target_crops": ["Grapes"],
        "target_diseases": ["Downy Mildew"],
        "recommended_dose": "1.0 g/L",
        "phi_days": 40
    }, headers=headers)

    # 2. Crop Mismatch Product (Sugarcane Bavistin)
    res2 = client.post("/api/inventory/pesticides", json={
        "product_name": "Farmer Bavistin 50 WP",
        "brand_name": "Bavistin",
        "formulation": "WP",
        "active_ingredients": [{"name": "Carbendazim", "concentration_value": 50.0, "concentration_unit": "%"}],
        "target_crops": ["Sugarcane"],
        "target_diseases": ["Red Rot"],
        "recommended_dose": "1.0 g/L"
    }, headers=headers)

    # 3. Product with Missing Composition (empty or mock)
    # We will simulate directly via service or created record
    return {
        "compatible_id": res1.json()["id"],
        "mismatch_id": res2.json()["id"]
    }

def test_13_compare_two_compatible_pesticides(setup_inventory_items):
    """13. Comparing two compatible pesticides."""
    headers = {"Authorization": "Bearer demo_token_secret_123"}
    payload = {
        "inventory_pesticide_id": setup_inventory_items["compatible_id"],
        "crop_id": "Grapes",
        "disease_id": "Downy Mildew",
        "weather_context": {
            "wind_speed_kmh": 8.0,
            "rain_probability": 10.0,
            "temperature_c": 26.0,
            "relative_humidity": 65.0,
            "spray_decision": "GOOD_TO_SPRAY"
        }
    }
    response = client.post("/api/inventory/pesticides/compare", json=payload, headers=headers)
    assert response.status_code == 200, response.text
    data = response.json()
    assert "comparison_id" in data
    assert data["overall_result"] in ["BOTH_SIMILAR", "INVENTORY_PRODUCT_MORE_SUITABLE", "RECOMMENDED_PRODUCT_MORE_SUITABLE"]
    assert len(data["criteria"]) == 7
    assert data["inventory_score"] > 60.0
    assert data["recommended_score"] > 60.0
    assert data["blockchain_record_id"] is not None

def test_14_compare_pesticide_with_missing_composition():
    """14. Comparing a pesticide with missing composition flags INSUFFICIENT_VERIFIED_DATA."""
    from backend.app.services.pesticide_comparison_service import pesticide_comparison_service
    res = pesticide_comparison_service.evaluate_comparison(
        inventory_item={"product_name": "No Chemical Info Bottle", "active_ingredients": []},
        crop="Grapes",
        disease="Downy Mildew"
    )
    assert res["overall_result"] == "INSUFFICIENT_VERIFIED_DATA"
    assert any("active ingredient could not be verified" in w.lower() for w in res["safety_warnings"])

def test_15_crop_mismatch_detection(setup_inventory_items):
    """15. Crop mismatch detection."""
    headers = {"Authorization": "Bearer demo_token_secret_123"}
    payload = {
        "inventory_pesticide_id": setup_inventory_items["mismatch_id"],
        "crop_id": "Grapes",  # Target is Grapes, but inventory item is registered only for Sugarcane
        "disease_id": "Downy Mildew",
        "weather_context": {"wind_speed_kmh": 5.0, "rain_probability": 5.0}
    }
    response = client.post("/api/inventory/pesticides/compare", json=payload, headers=headers)
    assert response.status_code == 200
    data = response.json()
    # Find Crop compatibility criterion
    crop_crit = next(c for c in data["criteria"] if "crop" in c["criterion"].lower())
    assert crop_crit["inventory_score"] <= 35.0
    assert "mismatch" in crop_crit["inventory_reason"].lower() or "excludes" in crop_crit["inventory_reason"].lower()

def test_16_disease_mismatch_detection(setup_inventory_items):
    """16. Disease mismatch detection."""
    headers = {"Authorization": "Bearer demo_token_secret_123"}
    payload = {
        "inventory_pesticide_id": setup_inventory_items["mismatch_id"],
        "crop_id": "Sugarcane",
        "disease_id": "Powdery Mildew", # Inventory is for Red Rot
        "weather_context": {"wind_speed_kmh": 5.0, "rain_probability": 5.0}
    }
    response = client.post("/api/inventory/pesticides/compare", json=payload, headers=headers)
    assert response.status_code == 200
    data = response.json()
    disease_crit = next(c for c in data["criteria"] if "disease" in c["criterion"].lower())
    assert disease_crit["inventory_score"] < 70.0

def test_17_weather_gatekeeper_override(setup_inventory_items):
    """17. Weather gatekeeper override (high wind > 15 km/h or rain > 40%)."""
    headers = {"Authorization": "Bearer demo_token_secret_123"}
    payload = {
        "inventory_pesticide_id": setup_inventory_items["compatible_id"],
        "crop_id": "Grapes",
        "disease_id": "Downy Mildew",
        "weather_context": {
            "wind_speed_kmh": 22.5,  # Exceeds 15 km/h limit!
            "rain_probability": 55.0, # Exceeds 40% threshold!
            "spray_decision": "DO_NOT_SPRAY"
        }
    }
    response = client.post("/api/inventory/pesticides/compare", json=payload, headers=headers)
    assert response.status_code == 200
    data = response.json()
    assert data["overall_result"] == "DO_NOT_SPRAY_WEATHER_OVERRIDE"
    assert data["weather_gatekeeper_status"] == "DO_NOT_SPRAY"
    assert any("drift" in w.lower() for w in data["safety_warnings"])
    assert any("wash-off" in w.lower() or "rain" in w.lower() for w in data["safety_warnings"])

def test_18_phi_mrl_warning_generation(setup_inventory_items):
    """18. PHI/MRL warning generation."""
    headers = {"Authorization": "Bearer demo_token_secret_123"}
    payload = {
        "inventory_pesticide_id": setup_inventory_items["compatible_id"],
        "crop_id": "Grapes",
        "disease_id": "Downy Mildew"
    }
    response = client.post("/api/inventory/pesticides/compare", json=payload, headers=headers)
    assert response.status_code == 200
    data = response.json()
    phi_crit = next(c for c in data["criteria"] if "phi" in c["criterion"].lower())
    assert phi_crit["inventory_score"] is not None
    assert "phi" in phi_crit["inventory_reason"].lower()

def test_19_blockchain_record_creation(setup_inventory_items):
    """19. Blockchain record creation."""
    headers = {"Authorization": "Bearer demo_token_secret_123"}
    payload = {
        "inventory_pesticide_id": setup_inventory_items["compatible_id"],
        "crop_id": "Grapes",
        "disease_id": "Downy Mildew"
    }
    response = client.post("/api/inventory/pesticides/compare", json=payload, headers=headers)
    assert response.status_code == 200
    blk_id = response.json()["blockchain_record_id"]
    assert blk_id is not None
    assert blk_id.startswith("blk_")

def test_20_blockchain_verification(setup_inventory_items):
    """20. Blockchain verification via /api/blockchain/verify/{record_id}."""
    headers = {"Authorization": "Bearer demo_token_secret_123"}
    payload = {
        "inventory_pesticide_id": setup_inventory_items["compatible_id"],
        "crop_id": "Grapes",
        "disease_id": "Downy Mildew"
    }
    comp_res = client.post("/api/inventory/pesticides/compare", json=payload, headers=headers)
    blk_id = comp_res.json()["blockchain_record_id"]

    verify_res = client.get(f"/api/blockchain/verify/{blk_id}")
    assert verify_res.status_code == 200, verify_res.text
    verify_data = verify_res.json()
    assert verify_data["record_id"] == blk_id
    assert "INTEGRITY VERIFIED" in verify_data["integrity_status"]

def test_21_comparison_with_insufficient_data():
    """21. Comparison with insufficient data."""
    from backend.app.services.pesticide_comparison_service import pesticide_comparison_service
    res = pesticide_comparison_service.evaluate_comparison(
        inventory_item={"product_name": "Blank Sample", "active_ingredients": []},
        crop="Grapes",
        disease="Downy Mildew"
    )
    assert res["overall_result"] == "INSUFFICIENT_VERIFIED_DATA"
    assert "insufficient verified information" in res["final_advisory"].lower()

def test_22_similar_score_handling():
    """22. Similar-score handling within threshold 5.0 -> BOTH_SIMILAR."""
    from backend.app.services.pesticide_comparison_service import pesticide_comparison_service
    res = pesticide_comparison_service.evaluate_comparison(
        inventory_item={
            "product_name": "Acrobat 50 WP",
            "active_ingredients": [{"name": "Dimethomorph", "concentration_value": 50.0}],
            "target_crops": ["Grapes"],
            "target_diseases": ["Downy Mildew"],
            "formulation": "WP",
            "recommended_dose": "1.0 g/L foliar spray",
            "phi_days": 40,
            "registration_number": "CIR-1122"
        },
        crop="Grapes",
        disease="Downy Mildew"
    )
    # Since both are Dimethomorph 50 WP for Grape Downy Mildew, difference is < 5
    assert res["overall_result"] == "BOTH_SIMILAR"
    assert "comparable suitability" in res["final_advisory"].lower()

if __name__ == "__main__":
    pytest.main([__file__, "-v"])
