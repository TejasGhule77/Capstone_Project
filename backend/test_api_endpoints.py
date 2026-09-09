"""
Automated Test Suite for AgriIntel Backend (Steps 3 - 9)
Validates:
- /health & Root
- Step 3: Auth Register, Login, Profile GET/PUT, Crop Selection, Multi-farm model
- Step 4: Real/Verified Crop Data (Strictly Onion, Grapes, Sugarcane, Wheat) & Stages
- Step 5: Weather API, Microclimate forecast, and Weather Gatekeeper (GOOD_TO_SPRAY, CAUTION, DO_NOT_SPRAY)
- Step 6: Crop Doctor AI Diagnosis with ML validation, severity, and risk estimation
- Step 7: Pesticide Recommendation + AHP Multi-Criteria Ranking + Weather Override
- Step 8: ETL Verification & Master Dataset Integrity
- Step 9: Blockchain SHA-256 Ledger & Record Verification (/blockchain/verify/{record_id})
- History & Chat
"""

import sys
import os

# Set standard output to utf-8 if supported
if sys.platform.startswith("win"):
    import io
    sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8', errors='replace')

# Add root to pythonpath
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), "..")))

from fastapi.testclient import TestClient
from backend.app.main import app

client = TestClient(app)

def test_health():
    response = client.get("/health")
    assert response.status_code == 200
    data = response.json()
    assert data["status"] == "healthy"
    assert data["supported_crops"] == ["Onion", "Grapes", "Sugarcane", "Wheat"]
    print("[PASS] Step 0: /health endpoint passed")

def test_auth_and_profile():
    # 1. Register with farm details
    reg_payload = {
        "name": "Sanjay Deshmukh",
        "email": "sanjay@agriintel.in",
        "mobile": "9988776655",
        "password": "secret_password",
        "village": "Ozar",
        "district": "Nashik",
        "state": "Maharashtra",
        "farm_size_acres": 5.0,
        "selected_crops": ["Grapes", "Onion"],
        "language": "mr",
        "farming_experience_years": 8
    }
    reg_resp = client.post("/api/auth/register", json=reg_payload)
    assert reg_resp.status_code == 200
    reg_data = reg_resp.json()
    token = reg_data["token"]
    assert reg_data["user"]["name"] == "Sanjay Deshmukh"
    assert len(reg_data["user"]["farms"]) > 0
    assert reg_data["user"]["farms"][0]["district"] == "Nashik"
    print("[PASS] Step 3: Auth Registration with Farm details passed")

    # 2. Login
    login_resp = client.post("/api/auth/login", json={"login": "9988776655", "password": "secret_password"})
    assert login_resp.status_code == 200
    assert login_resp.json()["user"]["mobile"] == "9988776655"
    print("[PASS] Step 3: Auth Login passed")

    # 3. Get Profile (both /profile and /api/auth/profile)
    prof_resp = client.get(f"/api/auth/profile?token={token}")
    assert prof_resp.status_code == 200
    assert prof_resp.json()["district"] == "Nashik"
    
    top_prof_resp = client.get(f"/profile?token={token}")
    assert top_prof_resp.status_code == 200
    print("[PASS] Step 3: Profile Fetch passed")

    # 4. Update Profile
    prof_data = prof_resp.json()
    prof_data["farm_size_acres"] = 6.5
    update_resp = client.put(f"/api/auth/profile?token={token}", json=prof_data)
    assert update_resp.status_code == 200
    assert update_resp.json()["farm_size_acres"] == 6.5
    print("[PASS] Step 3: Profile Update passed")

    # 5. Update Selected Crops
    crop_upd_resp = client.put(f"/api/auth/crops?token={token}", json={"selected_crops": ["Grapes", "Sugarcane"]})
    assert crop_upd_resp.status_code == 200
    assert "Sugarcane" in crop_upd_resp.json()["selected_crops"]
    print("[PASS] Step 3: Selected Crops Update passed")

def test_crops_data():
    resp = client.get("/api/crops")
    assert resp.status_code == 200
    crops = resp.json()
    crop_names = [c["crop_name"] for c in crops]
    assert sorted(crop_names) == sorted(["Onion", "Grapes", "Sugarcane", "Wheat"])
    for c in crops:
        assert c["verification_status"] in ["VERIFIED", "DEMO"]
        assert c["source"] != ""
    print("[PASS] Step 4: Crop Data (Strictly 4 crops) passed")

    # Single crop fetch
    single_resp = client.get("/api/crops/crop_grapes")
    assert single_resp.status_code == 200
    assert single_resp.json()["crop_name"] == "Grapes"
    print("[PASS] Step 4: Single Crop details passed")

def test_weather_and_gatekeeper():
    # 1. Weather Forecast
    resp = client.get("/api/weather?district=Nashik&latitude=19.9975&longitude=73.7898")
    assert resp.status_code == 200
    w_data = resp.json()
    assert "temperature_c" in w_data["current"]
    assert w_data["current"]["spray_condition"] in ["GOOD_TO_SPRAY", "CAUTION", "DO_NOT_SPRAY"]
    assert len(w_data["hourly_forecast"]) > 0
    print("[PASS] Step 5: Weather Forecast & Microclimate API passed")

    # 2. Weather Gatekeeper Evaluation (GOOD_TO_SPRAY)
    good_payload = {
        "crop": "Grapes",
        "crop_stage": "Shooting & Flowering",
        "disease": "Downy Mildew",
        "temperature": 26.5,
        "humidity": 65,
        "wind_speed": 8.0,
        "rain_probability": 10,
        "rainfall": 0.0
    }
    gk_good = client.post("/api/weather-gatekeeper", json=good_payload)
    assert gk_good.status_code == 200
    assert gk_good.json()["status"] == "GOOD_TO_SPRAY"
    print("[PASS] Step 5: Weather Gatekeeper (GOOD_TO_SPRAY) passed")

    # 3. Weather Gatekeeper Evaluation (DO_NOT_SPRAY due to wind > 15 km/h)
    bad_payload = {
        "crop": "Grapes",
        "temperature": 27.0,
        "humidity": 70,
        "wind_speed": 22.0,
        "rain_probability": 15,
        "rainfall": 0.0
    }
    gk_bad = client.post("/api/weather-gatekeeper", json=bad_payload)
    assert gk_bad.status_code == 200
    assert gk_bad.json()["status"] == "DO_NOT_SPRAY"
    print("[PASS] Step 5: Weather Gatekeeper (DO_NOT_SPRAY wind trigger) passed")

def test_crop_doctor_ml():
    # 1. Model Metadata & Evaluation Endpoints
    meta_resp = client.get("/api/crop-doctor/model-metadata")
    assert meta_resp.status_code == 200
    meta = meta_resp.json()
    assert meta["architecture"] == "ResNet-18"
    assert meta["num_classes"] == 39
    print("[PASS] Step 6: Model Metadata endpoint passed")

    eval_resp = client.get("/api/crop-doctor/evaluation")
    assert eval_resp.status_code == 200
    ev = eval_resp.json()
    assert ev["accuracy"] > 0.95
    print("[PASS] Step 6: Model Evaluation Metrics endpoint passed")

    # 2. Form Diagnostic (simulated leaf)
    resp = client.post("/api/crop-doctor/diagnose", data={"crop": "Grapes"})
    assert resp.status_code == 200
    diag = resp.json()
    assert diag["crop"] == "Grapes"
    assert len(diag["disease_name"]) > 0
    assert diag["confidence"] > 0.50
    assert diag["severity"] in ["Low", "Medium", "High"]
    assert len(diag["blockchain_hash"]) == 64
    print(f"[PASS] Step 6: Crop Doctor AI Diagnosis ({diag['disease_name']}, conf: {diag['confidence']*100:.1f}%) passed")

    # 3. Real Multipart File Upload with Actual Leaf Image
    leaf_path = os.path.join(
        os.path.dirname(__file__),
        "../AgriIntel/Agri/backend/media/disease_images/test_Grape___Black_rot.jpg"
    )
    if os.path.exists(leaf_path):
        with open(leaf_path, "rb") as f:
            files = {"image": ("test_Grape___Black_rot.jpg", f, "image/jpeg")}
            data = {"crop": "Grapes"}
            img_resp = client.post("/api/crop-doctor/diagnose", data=data, files=files)
            assert img_resp.status_code == 200
            img_diag = img_resp.json()
            assert img_diag["crop"] == "Grapes"
            assert "confidence" in img_diag
            assert img_diag["confidence"] > 0.50
            assert len(img_diag["blockchain_hash"]) == 64
            print(f"[PASS] Step 6: Real PyTorch ResNet-18 Inference on Leaf Image ({img_diag['disease_name']}, conf: {img_diag['confidence']*100:.1f}%) passed")

def test_pesticide_recommendation_and_ahp():
    # 1. Normal Recommendation (GOOD_TO_SPRAY)
    rec_payload = {
        "crop": "Grapes",
        "crop_stage": "Shooting & Flowering",
        "disease": "Downy Mildew",
        "severity": "Medium",
        "weather": {
            "temperature_c": 26.0,
            "humidity_pct": 65,
            "wind_speed_kmh": 7.5,
            "rain_probability_pct": 10
        }
    }
    resp = client.post("/api/recommend", json=rec_payload)
    assert resp.status_code == 200
    data = resp.json()
    assert data["is_spray_allowed"] == True
    assert len(data["ranking"]) > 0
    assert data["ranking"][0]["rank"] == 1
    assert data["ranking"][0]["ahp_score"] >= data["ranking"][-1]["ahp_score"]
    print("[PASS] Step 7: AHP Pesticide Recommendation Ranking passed")

    # 2. Weather Override Recommendation (DO_NOT_SPRAY)
    rec_override_payload = {
        "crop": "Grapes",
        "disease": "Downy Mildew",
        "severity": "High",
        "weather": {
            "temperature_c": 28.0,
            "humidity_pct": 85,
            "wind_speed_kmh": 24.0,  # Elevated wind
            "rain_probability_pct": 65  # Elevated rain
        }
    }
    resp_ov = client.post("/api/recommend", json=rec_override_payload)
    assert resp_ov.status_code == 200
    data_ov = resp_ov.json()
    assert data_ov["is_spray_allowed"] == False
    assert data_ov["weather_gatekeeper_status"] == "DO_NOT_SPRAY"
    assert data_ov["spray_override_warning"] is not None
    print("[PASS] Step 7: Weather Gatekeeper Safety Override Warning passed")

    # 3. AHP Matrix Evaluation
    ahp_resp = client.post("/api/ahp/evaluate", json={"district": "Nashik", "irrigation_available": True})
    assert ahp_resp.status_code == 200
    assert ahp_resp.json()["is_matrix_valid"] == True
    assert ahp_resp.json()["consistency_ratio"] < 0.10
    print("[PASS] Step 7: AHP Decision Matrix Consistency (CR < 0.10) passed")

def test_advisories_and_pesticides():
    adv_resp = client.get("/api/advisories")
    assert adv_resp.status_code == 200
    assert len(adv_resp.json()) > 0
    print("[PASS] Step 4 & 7: Advisories API passed")

    pest_resp = client.get("/api/pesticides?crop=Grapes")
    assert pest_resp.status_code == 200
    assert len(pest_resp.json()) > 0
    for p in pest_resp.json():
        assert p["verification_status"] == "VERIFIED"
    print("[PASS] Step 4 & 7: Verified Pesticides Registry API passed")

def test_blockchain_integrity():
    # 1. Verify specific block
    ver_resp = client.get("/api/blockchain/verify/blk_000")
    assert ver_resp.status_code == 200
    v_data = ver_resp.json()
    assert v_data["integrity_status"] == "INTEGRITY VERIFIED"
    assert len(v_data["stored_hash"]) == 64
    print("[PASS] Step 9: Blockchain Record Verification (/blockchain/verify/{record_id}) passed")

    # 2. Audit Trail
    trail_resp = client.get("/api/integrity/audit-trail")
    assert trail_resp.status_code == 200
    assert trail_resp.json()["is_valid_chain"] == True
    print("[PASS] Step 9: Cryptographic Blockchain Chain Audit passed")

def test_history_and_chat():
    hist_resp = client.get("/api/history?crop=Grapes")
    assert hist_resp.status_code == 200
    assert len(hist_resp.json()) > 0
    print("[PASS] Step 3 & 9: Farmer History API passed")

    chat_resp = client.post("/api/chat", json={"message": "What should I spray for Downy Mildew in Grapes?", "crop": "Grapes"})
    assert chat_resp.status_code == 200
    assert len(chat_resp.json()["reply"]) > 0
    print("[PASS] Step 6 & 7: AI Agronomy Chat Assistant passed")

if __name__ == "__main__":
    print("\n==================================================================")
    print("   AGRIINTEL BACKEND AUTOMATED INTEGRATION TEST SUITE (STEPS 3 - 9)")
    print("==================================================================")
    test_health()
    test_auth_and_profile()
    test_crops_data()
    test_weather_and_gatekeeper()
    test_crop_doctor_ml()
    test_pesticide_recommendation_and_ahp()
    test_advisories_and_pesticides()
    test_blockchain_integrity()
    test_history_and_chat()
    print("\n>>> ALL BACKEND API & DATA TESTS PASSED WITH 100% SUCCESS <<<\n")
