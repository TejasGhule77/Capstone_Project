from typing import List, Optional, Dict, Any
from pydantic import BaseModel, Field

# ----------------- Active Ingredients -----------------
class ActiveIngredientInput(BaseModel):
    name: str
    concentration: Optional[str] = None
    concentration_value: Optional[float] = None
    concentration_unit: Optional[str] = "%"
    role: Optional[str] = "fungicide"

class ActiveIngredientResponse(BaseModel):
    id: Optional[str] = None
    name: str
    concentration: Optional[str] = None
    concentration_value: Optional[float] = None
    concentration_unit: Optional[str] = "%"
    role: Optional[str] = "fungicide"
    confidence: Optional[float] = 1.0

# ----------------- Image Upload & OCR -----------------
class ImageUploadResponse(BaseModel):
    image_id: str
    image_url: str
    sha256: str
    mime_type: str
    size_bytes: int
    status: str = "UPLOADED"

class OCRProcessRequest(BaseModel):
    image_ids: List[str]

class OCRProcessResponse(BaseModel):
    ocr_job_id: str
    status: str
    raw_text: str
    extracted_fields: Dict[str, Any]
    field_confidence: Dict[str, Any]
    ocr_confidence: float
    fields_requiring_confirmation: List[str]
    verification_status: str = "PENDING_VERIFICATION"

# ----------------- Inventory CRUD -----------------
class PesticideCreateRequest(BaseModel):
    product_name: Optional[str] = None
    brand_name: Optional[str] = None
    manufacturer: Optional[str] = None
    formulation: Optional[str] = None
    product_type: Optional[str] = "Fungicide"
    registration_number: Optional[str] = None
    batch_number: Optional[str] = None
    manufacturing_date: Optional[str] = None
    expiry_date: Optional[str] = None
    quantity_value: Optional[float] = None
    quantity_unit: Optional[str] = "kg"
    active_ingredients: List[ActiveIngredientInput] = []
    target_crops: Optional[List[str]] = []
    target_diseases: Optional[List[str]] = []
    recommended_dose: Optional[str] = None
    phi_days: Optional[int] = None
    mrl_value: Optional[str] = None
    safety_instructions: Optional[str] = None
    signal_word: Optional[str] = "CAUTION"
    image_ids: Optional[List[str]] = []
    front_image_url: Optional[str] = None
    back_image_url: Optional[str] = None
    composition_image_url: Optional[str] = None
    instruction_image_url: Optional[str] = None
    ocr_confidence: Optional[float] = None
    raw_ocr_text: Optional[str] = None
    verification_status: Optional[str] = "VERIFIED_BY_FARMER"

class PesticideUpdateRequest(BaseModel):
    product_name: Optional[str] = None
    brand_name: Optional[str] = None
    manufacturer: Optional[str] = None
    formulation: Optional[str] = None
    product_type: Optional[str] = None
    registration_number: Optional[str] = None
    batch_number: Optional[str] = None
    manufacturing_date: Optional[str] = None
    expiry_date: Optional[str] = None
    quantity_value: Optional[float] = None
    quantity_unit: Optional[str] = None
    active_ingredients: Optional[List[ActiveIngredientInput]] = None
    target_crops: Optional[List[str]] = None
    target_diseases: Optional[List[str]] = None
    recommended_dose: Optional[str] = None
    phi_days: Optional[int] = None
    mrl_value: Optional[str] = None
    safety_instructions: Optional[str] = None
    signal_word: Optional[str] = None
    verification_status: Optional[str] = None

class PesticideResponse(BaseModel):
    id: str
    farmer_id: str
    farm_id: Optional[str] = None
    product_name: Optional[str] = None
    brand_name: Optional[str] = None
    manufacturer: Optional[str] = None
    formulation: Optional[str] = None
    product_type: Optional[str] = None
    registration_number: Optional[str] = None
    registration_status: str = "UNKNOWN"
    batch_number: Optional[str] = None
    manufacturing_date: Optional[str] = None
    expiry_date: Optional[str] = None
    quantity_value: Optional[float] = None
    quantity_unit: Optional[str] = None
    target_crops: Optional[List[str]] = []
    target_diseases: Optional[List[str]] = []
    recommended_dose: Optional[str] = None
    phi_days: Optional[int] = None
    mrl_value: Optional[str] = None
    safety_instructions: Optional[str] = None
    signal_word: Optional[str] = None
    source_type: str = "FARMER_LABEL"
    verification_status: str = "PENDING_VERIFICATION"
    inventory_status: str = "AVAILABLE"  # AVAILABLE, EXPIRED, EXPIRING_SOON, ARCHIVED
    ocr_confidence: Optional[float] = None
    front_image_url: Optional[str] = None
    back_image_url: Optional[str] = None
    composition_image_url: Optional[str] = None
    instruction_image_url: Optional[str] = None
    blockchain_record_id: Optional[str] = None
    active_ingredients: List[ActiveIngredientResponse] = []
    created_at: str
    updated_at: str

class PesticideListResponse(BaseModel):
    items: List[PesticideResponse]
    total: int

class DuplicateCheckResponse(BaseModel):
    is_duplicate: bool
    matching_inventory_id: Optional[str] = None
    message: Optional[str] = None

# ----------------- Comparison -----------------
class WeatherContext(BaseModel):
    wind_speed_kmh: float = 8.0
    rain_probability: float = 10.0
    temperature_c: Optional[float] = 25.0
    relative_humidity: Optional[float] = 70.0
    spray_decision: Optional[str] = "GOOD_TO_SPRAY"

class PesticideCompareRequest(BaseModel):
    inventory_pesticide_id: str
    recommended_pesticide_id: Optional[str] = None
    crop_id: str
    disease_id: Optional[str] = None
    diagnosis_id: Optional[str] = None
    weather_context: Optional[WeatherContext] = None

class ComparisonCriterionResult(BaseModel):
    criterion: str
    weight: float
    inventory_score: Optional[float] = None
    recommended_score: Optional[float] = None
    inventory_reason: str
    recommended_reason: str
    source: str
    confidence: float = 0.9

class PesticideCompareResponse(BaseModel):
    comparison_id: str
    crop: str
    problem: str
    overall_result: str  # INVENTORY_PRODUCT_MORE_SUITABLE, RECOMMENDED_PRODUCT_MORE_SUITABLE, BOTH_SIMILAR, NEITHER_SUITABLE, INSUFFICIENT_VERIFIED_DATA, DO_NOT_SPRAY_WEATHER_OVERRIDE
    confidence: float
    inventory_score: Optional[float] = None
    recommended_score: Optional[float] = None
    inventory_product: Dict[str, Any]
    recommended_product: Dict[str, Any]
    criteria: List[ComparisonCriterionResult]
    safety_warnings: List[str]
    weather_gatekeeper_status: str
    final_advisory: str
    disclaimer: str
    blockchain_record_id: Optional[str] = None
    created_at: str
