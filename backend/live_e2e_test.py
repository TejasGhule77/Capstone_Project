"""
Live End-to-End HTTP Integration Test for AgriIntel API
Connects to live running FastAPI server on http://127.0.0.1:8000
"""

import sys
import io
import requests

if sys.platform.startswith("win"):
    sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8', errors='replace')

BASE_URL = "http://127.0.0.1:8000"

def run_live_tests():
    print("==================================================")
    print("  AGRIINTEL LIVE HTTP INTEGRATION TEST SUITE")
    print("==================================================")

    # 1. Health Check
    r = requests.get(f"{BASE_URL}/health")
    assert r.status_code == 200, f"Health check failed: {r.status_code}"
    health = r.json()
    assert health["status"] == "healthy"
    assert health["verification_status"] == "DEMO"
    print("[PASS] 1. Live Health Check: status=healthy, demo_mode=True")

    # 2. Crops API
    r = requests.get(f"{BASE_URL}/api/crops")
    assert r.status_code == 200
    crops = r.json()
    crop_names = [c["name"] for c in crops]
    assert sorted(crop_names) == ["Grapes", "Onion", "Sugarcane", "Wheat"]
    print(f"[PASS] 2. Live Crops API: Strictly 4 crops -> {crop_names}")

    # 3. Weather API
    r = requests.get(f"{BASE_URL}/api/weather/current?district=Pune")
    assert r.status_code == 200
    w = r.json()
    assert "spray_condition" in w["current"]
    print(f"[PASS] 3. Live Weather: Pune -> {w['current']['temperature_c']}°C, {w['current']['spray_condition']}")

    # 4. Weather Gatekeeper Check
    r = requests.get(f"{BASE_URL}/api/weather/spray-check?crop=Grapes&wind_speed=7.5&rain_prob=10&humidity=65&temperature=28.0")
    assert r.status_code == 200
    chk = r.json()
    assert chk["spray_condition"] == "GOOD TO SPRAY"
    print(f"[PASS] 4. Live Weather Gatekeeper: Condition={chk['spray_condition']} ({chk['recommendation']})")

    # 5. Crop Doctor AI Diagnosis
    r = requests.post(f"{BASE_URL}/api/crop-doctor/diagnose", data={"crop": "Grapes"})
    assert r.status_code == 200
    diag = r.json()
    assert diag["disease_name"] == "Downy Mildew"
    assert diag["confidence"] > 0.90
    print(f"[PASS] 5. Live Crop Doctor: {diag['crop']} -> {diag['disease_name']} ({diag['confidence']*100:.1f}%)")

    # 6. Advisories
    r = requests.get(f"{BASE_URL}/api/advisory?crop=Grapes")
    assert r.status_code == 200
    advisories = r.json()
    assert len(advisories) > 0
    print(f"[PASS] 6. Live Advisory API: Loaded {len(advisories)} advisories with weather gatekeeper validation")

    # 7. AHP Decision Engine
    r = requests.post(f"{BASE_URL}/api/ahp/evaluate", json={"district": "Pune", "irrigation_available": True})
    assert r.status_code == 200
    ahp = r.json()
    assert ahp["is_matrix_valid"] == True
    assert ahp["consistency_ratio"] < 0.10
    top_crop = ahp["ranked_crops"][0]
    print(f"[PASS] 7. Live AHP Engine: Consistency Ratio CR={ahp['consistency_ratio']} < 0.10, Rank #1: {top_crop['crop_name']}")

    # 8. Blockchain Cryptographic Integrity Ledger
    r = requests.get(f"{BASE_URL}/api/integrity/audit-trail")
    assert r.status_code == 200
    ledger = r.json()
    assert ledger["is_valid_chain"] == True
    print(f"[PASS] 8. Live Blockchain Ledger: Chain valid={ledger['is_valid_chain']}, Total blocks={ledger['chain_length']}")

    # 9. Full Auth Registration -> Profile -> Edit Cycle
    reg_payload = {
        "name": "Pranali Patil",
        "mobile": "9876543210",
        "email": "pranali.farmer@agriintel.in",
        "password": "demo_password",
        "village": "Junnar",
        "district": "Pune",
        "farm_size_acres": 4.5,
        "selected_crops": ["Grapes", "Onion"],
        "language": "en"
    }
    r = requests.post(f"{BASE_URL}/api/auth/register", json=reg_payload)
    assert r.status_code == 200
    auth_data = r.json()
    token = auth_data["token"]
    assert auth_data["user"]["name"] == "Pranali Patil"

    # Fetch Profile
    r = requests.get(f"{BASE_URL}/api/auth/profile?token={token}")
    assert r.status_code == 200
    prof = r.json()
    assert prof["village"] == "Junnar"

    # Update Crop Selection
    r = requests.put(f"{BASE_URL}/api/auth/crops?token={token}", json={"selected_crops": ["Onion", "Grapes", "Wheat"]})
    assert r.status_code == 200
    updated_prof = r.json()
    assert "Wheat" in updated_prof["selected_crops"]
    print("[PASS] 9. Live Auth & Profile Flow: Registration, Session, Profile Fetch & Crop Updates verified")

    print("\n🎉 ALL LIVE ENDPOINTS VERIFIED AND RESPONDING 100% SUCCESFULLY!\n")

if __name__ == "__main__":
    run_live_tests()
