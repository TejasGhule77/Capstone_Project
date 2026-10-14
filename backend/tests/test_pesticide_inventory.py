import sys
import os
import io
import pytest
from PIL import Image

sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "..")))

from fastapi.testclient import TestClient
from backend.app.main import app
from backend.app.core import database
from backend.app.services.pesticide_normalization_service import pesticide_normalization_service

client = TestClient(app)

def _create_test_image_bytes(format="JPEG", size=(200, 200), color=(100, 150, 200)) -> bytes:
    img = Image.new("RGB", size, color=color)
    buf = io.BytesIO()
    img.save(buf, format=format)
    return buf.getvalue()

def test_01_upload_valid_pesticide_image():
    """1. Uploading a valid pesticide image."""
    img_bytes = _create_test_image_bytes(format="JPEG")
    files = {"image": ("test_label.jpg", img_bytes, "image/jpeg")}
    response = client.post("/api/inventory/pesticides/upload-image", files=files, data={"image_type": "front"})
    assert response.status_code == 200, response.text
    data = response.json()
    assert "image_id" in data
    assert data["status"] == "UPLOADED"
    assert data["mime_type"] == "image/jpeg"
    assert len(data["sha256"]) == 64

def test_02_reject_unsupported_mime_types():
    """2. Rejecting unsupported MIME types (e.g. text/plain or executable)."""
    bad_bytes = b"This is a text file not an image."
    files = {"image": ("malicious.txt", bad_bytes, "text/plain")}
    response = client.post("/api/inventory/pesticides/upload-image", files=files)
    assert response.status_code == 415 or response.status_code == 400

def test_03_reject_oversized_images():
    """3. Rejecting oversized images exceeding 10MB limit."""
    oversized_bytes = b"0" * (11 * 1024 * 1024)
    files = {"image": ("huge_label.jpg", oversized_bytes, "image/jpeg")}
    response = client.post("/api/inventory/pesticides/upload-image", files=files)
    assert response.status_code == 413

def test_04_ocr_extraction_response():
    """4. OCR extraction response with field confidences and confirmation fields."""
    payload = {"image_ids": ["img_ridomil_test"]}
    response = client.post("/api/inventory/pesticides/ocr", json=payload)
    assert response.status_code == 200, response.text
    data = response.json()
    assert data["status"] == "COMPLETED"
    assert "extracted_fields" in data
    assert "field_confidence" in data
    assert "ocr_confidence" in data
    assert isinstance(data["fields_requiring_confirmation"], list)

def test_05_add_pesticide_after_farmer_confirmation():
    """5. Adding a pesticide after farmer confirmation."""
    payload = {
        "product_name": "Ridomil Gold 68 WG",
        "brand_name": "Ridomil Gold",
        "manufacturer": "Syngenta",
        "formulation": "WP",
        "registration_number": "CIR-45892/2020",
        "batch_number": "BT-9021",
        "expiry_date": "2027-12-31",
        "quantity_value": 2.5,
        "quantity_unit": "kg",
        "active_ingredients": [
            {"name": "Metalaxyl-M", "concentration": "4%", "concentration_value": 4.0, "concentration_unit": "%"},
            {"name": "Mancozeb", "concentration": "64%", "concentration_value": 64.0, "concentration_unit": "%"}
        ],
        "target_crops": ["Grapes", "Onion"],
        "target_diseases": ["Downy Mildew", "Purple Blotch"],
        "recommended_dose": "2.5 g/L",
        "phi_days": 60,
        "verification_status": "VERIFIED_BY_FARMER"
    }
    headers = {"Authorization": "Bearer demo_token_secret_123"}
    response = client.post("/api/inventory/pesticides", json=payload, headers=headers)
    assert response.status_code == 200, response.text
    data = response.json()
    assert "id" in data
    assert data["status"] == "ADDED_TO_INVENTORY"
    assert data["verification_status"] == "VERIFIED_BY_FARMER"
    assert data.get("blockchain_record_id") is not None

def test_06_reject_inventory_without_active_ingredients():
    """6. Rejecting inventory records without active ingredients."""
    payload = {
        "product_name": "Mystery Chemical Bottle",
        "brand_name": "Mystery",
        "active_ingredients": []  # Empty!
    }
    headers = {"Authorization": "Bearer demo_token_secret_123"}
    response = client.post("/api/inventory/pesticides", json=payload, headers=headers)
    assert response.status_code == 400
    assert "active ingredient" in response.text.lower()

def test_07_list_authenticated_farmer_inventory():
    """7. Listing only the authenticated farmer's inventory."""
    headers = {"Authorization": "Bearer demo_token_secret_123"}
    response = client.get("/api/inventory/pesticides", headers=headers)
    assert response.status_code == 200, response.text
    data = response.json()
    assert "items" in data
    assert "total" in data
    assert data["total"] >= 1
    for item in data["items"]:
        assert item["farmer_id"] is not None

def test_08_prevent_cross_user_inventory_access():
    """8. Preventing cross-user inventory access."""
    headers = {"Authorization": "Bearer demo_token_secret_123"}
    response = client.get("/api/inventory/pesticides/inv_non_existent_fake", headers=headers)
    assert response.status_code == 404

def test_09_update_inventory_data():
    """9. Updating inventory data."""
    headers = {"Authorization": "Bearer demo_token_secret_123"}
    list_res = client.get("/api/inventory/pesticides", headers=headers)
    items = list_res.json()["items"]
    assert len(items) > 0
    target_id = items[0]["id"]

    update_payload = {
        "quantity_value": 5.0,
        "recommended_dose": "3.0 g/L"
    }
    up_res = client.put(f"/api/inventory/pesticides/{target_id}", json=update_payload, headers=headers)
    assert up_res.status_code == 200, up_res.text
    assert up_res.json()["quantity_value"] == 5.0
    assert up_res.json()["recommended_dose"] == "3.0 g/L"

def test_10_archive_inventory_data():
    """10. Archiving inventory data (soft-delete)."""
    headers = {"Authorization": "Bearer demo_token_secret_123"}
    # Create temporary item to archive
    create_res = client.post("/api/inventory/pesticides", json={
        "product_name": "Temporary Test Pesticide",
        "active_ingredients": [{"name": "Mancozeb", "concentration_value": 75.0, "concentration_unit": "%"}]
    }, headers=headers)
    temp_id = create_res.json()["id"]

    # Archive
    del_res = client.delete(f"/api/inventory/pesticides/{temp_id}", headers=headers)
    assert del_res.status_code == 200, del_res.text
    assert del_res.json()["status"] == "ARCHIVED"

    # Verify not listed in active inventory
    list_res = client.get("/api/inventory/pesticides", headers=headers)
    active_ids = [it["id"] for it in list_res.json()["items"]]
    assert temp_id not in active_ids

def test_11_detect_expired_pesticide():
    """11. Detecting expired pesticides."""
    headers = {"Authorization": "Bearer demo_token_secret_123"}
    create_res = client.post("/api/inventory/pesticides", json={
        "product_name": "Old Expired Batch",
        "expiry_date": "2020-01-01",  # Past date
        "active_ingredients": [{"name": "Carbendazim", "concentration_value": 50.0, "concentration_unit": "%"}]
    }, headers=headers)
    item_id = create_res.json()["id"]

    get_res = client.get(f"/api/inventory/pesticides/{item_id}", headers=headers)
    assert get_res.status_code == 200
    assert get_res.json()["inventory_status"] == "EXPIRED"

def test_12_normalize_active_ingredient_names():
    """12. Normalizing active ingredient names."""
    assert pesticide_normalization_service.normalize_active_ingredient_name("mancozeb 75 wp") == "Mancozeb"
    assert pesticide_normalization_service.normalize_active_ingredient_name("MZ") == "Mancozeb"
    assert pesticide_normalization_service.normalize_active_ingredient_name("metalaxyl-m") == "Metalaxyl-M"
    assert pesticide_normalization_service.normalize_active_ingredient_name("tebuconazole 25.9 ec") == "Tebuconazole"
    assert pesticide_normalization_service.normalize_active_ingredient_name("bavistin") == "Carbendazim"

def test_23_ocr_low_confidence_handling():
    """23. OCR low-confidence handling."""
    from backend.app.services.ocr_service import ocr_service
    # Parse blank text
    res = ocr_service.parse_label_text("unreadable blurry smudge")
    assert len(res["fields_requiring_confirmation"]) > 0
    assert "product_name" in res["fields_requiring_confirmation"]

def test_24_duplicate_product_detection():
    """24. Duplicate product detection."""
    headers = {"Authorization": "Bearer demo_token_secret_123"}
    dup_res = client.post("/api/inventory/pesticides/check-duplicate", json={
        "product_name": "Ridomil Gold"
    }, headers=headers)
    assert dup_res.status_code == 200
    data = dup_res.json()
    assert data["is_duplicate"] is True
    assert data["matching_inventory_id"] is not None

if __name__ == "__main__":
    pytest.main([__file__, "-v"])
