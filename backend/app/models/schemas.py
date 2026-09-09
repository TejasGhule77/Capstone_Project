from typing import List, Optional, Dict, Any
from pydantic import BaseModel, Field

# User & Auth Schemas
class UserRegisterRequest(BaseModel):
    name: str
    email: Optional[str] = None
    mobile: str
    password: str
    confirm_password: Optional[str] = None
    village: Optional[str] = "Nashik"
    district: Optional[str] = "Nashik"
    state: Optional[str] = "Maharashtra"
    farm_size_acres: Optional[float] = 2.5
    selected_crops: Optional[List[str]] = ["Grapes", "Onion"]
    language: Optional[str] = "en"
    farming_experience_years: Optional[int] = 5

class UserLoginRequest(BaseModel):
    login: str  # mobile or email
    password: str

class FarmModel(BaseModel):
    farm_id: str
    user_id: str
    farm_name: str
    village: str
    district: str
    state: str = "Maharashtra"
    latitude: Optional[float] = 18.5204
    longitude: Optional[float] = 73.8567
    area: float
    area_unit: str = "Acres"  # Acres | Hectares | Guntha
    soil_type: Optional[str] = "Clay loam"
    irrigation_type: Optional[str] = "Drip Irrigation"
    created_at: Optional[str] = None
    updated_at: Optional[str] = None

class UserProfile(BaseModel):
    id: str
    name: str
    email: Optional[str] = None
    mobile: str
    village: str
    district: str
    state: str = "Maharashtra"
    farm_size_acres: float
    selected_crops: List[str]
    language: str = "en"
    farming_experience_years: int = 5
    farms: List[FarmModel] = []
    is_demo: bool = True
    verification_status: str = "DEMO"

class AuthResponse(BaseModel):
    token: str
    token_type: str = "bearer"
    user: UserProfile
    verification_status: str = "DEMO"

# Crop Schemas
class CropDetail(BaseModel):
    crop_id: str
    crop_name: str
    scientific_name: str
    crop_type: str
    marathi_name: Optional[str] = None
    season: Optional[List[str]] = []
    duration_days: Optional[int] = 120
    major_districts: Optional[List[str]] = []
    stages: Optional[List[Dict[str, Any]]] = []
    verification_status: str = "VERIFIED"
    source: str = "ICAR"
    source_url: str = ""
    last_verified: str = "2026-08-20"

class CropSelectionUpdateRequest(BaseModel):
    selected_crops: List[str]

# Weather Schemas
class WeatherRequest(BaseModel):
    latitude: float = 18.5204
    longitude: float = 73.8567
    district: Optional[str] = "Pune"

class CurrentWeather(BaseModel):
    temperature_c: float
    feels_like_c: Optional[float] = None
    humidity_pct: int
    wind_speed_kmh: float
    wind_direction: Optional[str] = "WSW"
    rainfall_mm: Optional[float] = 0.0
    rain_probability_pct: int
    weather_condition: str
    weather_risks: Optional[Dict[str, str]] = None
    spray_condition: str  # GOOD_TO_SPRAY | CAUTION | DO_NOT_SPRAY
    spray_reason: str
    is_demo: bool = True
    verification_status: str = "DEMO"

class WeatherResponse(BaseModel):
    district: str
    state: str = "Maharashtra"
    latitude: Optional[float] = 18.5204
    longitude: Optional[float] = 73.8567
    current: CurrentWeather
    hourly_forecast: List[Dict[str, Any]] = []
    daily_forecast: List[Dict[str, Any]] = []
    verification_status: str = "DEMO"

class SprayGatekeeperCheck(BaseModel):
    crop_name: str
    temperature_c: float
    humidity_pct: int
    wind_speed_kmh: float
    rain_probability_pct: int
    spray_condition: str  # GOOD_TO_SPRAY | CAUTION | DO_NOT_SPRAY
    recommendation: str
    verification_status: str = "DEMO"

class WeatherGatekeeperRequest(BaseModel):
    crop: str = "Grapes"
    crop_stage: Optional[str] = "Shooting & Flowering"
    disease: Optional[str] = "Downy Mildew"
    temperature: float = 28.0
    humidity: int = 65
    wind_speed: float = 8.5
    rain_probability: int = 10
    rainfall: float = 0.0
    forecast: Optional[str] = "Clear"

class WeatherGatekeeperResponse(BaseModel):
    status: str  # GOOD_TO_SPRAY | CAUTION | DO_NOT_SPRAY
    reason: str
    risk_factors: Dict[str, str]
    temperature_assessment: str
    wind_assessment: str
    humidity_assessment: str
    rain_assessment: str
    verification_status: str = "VERIFIED"
    source: str = "ICAR-NRCG Agromet Rules & IMD"

# Crop Doctor & Diagnosis Schemas
class DiagnosisRequest(BaseModel):
    crop: str = "Grapes"
    image_filename: Optional[str] = "leaf_sample.jpg"

class DiagnosisResponse(BaseModel):
    diagnosis_id: str
    crop: str
    disease_name: str
    pathogen: str
    marathi_name: str
    hindi_name: Optional[str] = None
    confidence: float
    severity: str  # Low | Medium | High
    disease_risk: str  # Low | Medium | High
    symptoms: str
    weather_risk: str
    recommendation: str
    organic_treatment: str
    chemical_treatment: str
    source: str
    source_url: str
    verification_status: str  # VERIFIED | DEMO
    blockchain_hash: str
    timestamp: str

# Pesticide & Recommendation Schemas
class PesticideItem(BaseModel):
    pesticide_id: str
    active_ingredient: str
    product_name: str
    crop: str
    target_problem: str
    formulation: str
    label_claim: str
    phi: str
    mrl: str
    source: str
    source_url: str
    verification_status: str
    last_verified: str

class RecommendationRequest(BaseModel):
    crop: str = "Grapes"
    crop_stage: Optional[str] = "Shooting & Flowering"
    disease: Optional[str] = "Downy Mildew"
    severity: Optional[str] = "Medium"
    weather: Optional[Dict[str, Any]] = None

class CandidateRecommendation(BaseModel):
    pesticide_id: str
    product_name: str
    active_ingredient: str
    target_problem: str
    ahp_score: float
    rank: int
    problem_relevance: str
    weather_suitability: str
    source_status: str
    phi_compliance: str
    verification_status: str
    source: str
    reasons: str

class RecommendationResponse(BaseModel):
    crop: str
    disease: str
    weather_gatekeeper_status: str
    weather_gatekeeper_reason: str
    is_spray_allowed: bool
    spray_override_warning: Optional[str] = None
    ranking: List[CandidateRecommendation]
    ahp_criteria_weights: Dict[str, float]
    verification_status: str
    blockchain_hash: str
    timestamp: str

# AHP Evaluation Schemas
class AHPEvaluateRequest(BaseModel):
    district: Optional[str] = "Pune"
    soil_type: Optional[str] = "Clay loam"
    irrigation_available: bool = True
    budget_level: Optional[str] = "Medium"

class AHPCropScore(BaseModel):
    crop_name: str
    composite_score: float
    rank: int
    expected_yield: float
    projected_profit: float
    justification: str
    verification_status: str = "DEMO"

class AHPResponse(BaseModel):
    ranked_crops: List[AHPCropScore]
    is_matrix_valid: bool = True
    consistency_ratio: float = 0.042
    verification_status: str = "DEMO"

# Advisory Schemas
class AdvisoryItem(BaseModel):
    id: str
    crop_name: str
    crop_id: Optional[str] = None
    stage: str
    alert_type: str
    title: str
    summary: str
    action_points: List[str]
    weather_gatekeeper_status: str
    ahp_score: float
    blockchain_proof: str
    verification_status: str = "DEMO"
    source: Optional[str] = "ICAR"

# History & Chat Schemas
class HistoryRecord(BaseModel):
    record_id: str
    user_id: str
    crop: str
    type: str  # DIAGNOSIS | RECOMMENDATION | SPRAY_LOG
    title: str
    details: Dict[str, Any]
    blockchain_hash: str
    timestamp: str
    verification_status: str

class ChatMessageRequest(BaseModel):
    message: str
    crop: Optional[str] = "Grapes"
    language: Optional[str] = "en"

class ChatMessageResponse(BaseModel):
    reply: str
    suggested_actions: List[str]
    verification_status: str = "DEMO"

# Blockchain Schemas
class BlockchainVerifyResponse(BaseModel):
    record_id: str
    current_hash: str
    stored_hash: str
    integrity_status: str  # INTEGRITY VERIFIED | INTEGRITY CHECK FAILED
    timestamp: str
    source: str
    verification_status: str

class IntegrityBlock(BaseModel):
    block_index: int
    timestamp: str
    record_type: str
    data_payload: Dict[str, Any]
    previous_hash: str
    block_hash: str
    verification_status: str = "DEMO"

class IntegrityAuditTrailResponse(BaseModel):
    chain_length: int
    is_valid_chain: bool
    blocks: List[Dict[str, Any]]
    verification_status: str = "DEMO"
