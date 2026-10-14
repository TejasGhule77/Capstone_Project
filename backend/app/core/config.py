import os
from pydantic_settings import BaseSettings

class Settings(BaseSettings):
    PROJECT_NAME: str = "AgriIntel Precision Agro-Intelligence Engine"
    API_V1_STR: str = "/api"
    VERSION: str = "2.0.0"
    ENVIRONMENT: str = "development"
    DEMO_MODE: bool = True
    
    # OpenWeather Configuration
    OPENWEATHER_API_KEY: str = os.getenv("OPENWEATHER_API_KEY", "")
    
    # Supported Core Crops
    SUPPORTED_CROPS: list[str] = ["Onion", "Grapes", "Sugarcane", "Wheat"]

    # CORS
    CORS_ORIGINS: list[str] = [
        "http://localhost",
        "http://localhost:3000",
        "http://localhost:8000",
        "http://localhost:8080",
        "http://127.0.0.1",
        "http://127.0.0.1:8000",
        "http://127.0.0.1:3000",
        "http://127.0.0.1:8080",
        "*",
    ]
    
    # Data Paths
    BASE_DIR: str = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "..", ".."))
    DATA_DIR: str = os.path.join(BASE_DIR, "data")
    DATA_DEMO_DIR: str = os.path.join(BASE_DIR, "data", "demo")
    MODELS_DIR: str = os.path.join(BASE_DIR, "models")
    
    # Pesticide Inventory & Comparison Configuration
    OCR_PROVIDER: str = os.getenv("OCR_PROVIDER", "tesseract")
    MAX_PESTICIDE_IMAGE_SIZE_MB: int = int(os.getenv("MAX_PESTICIDE_IMAGE_SIZE_MB", "10"))
    PESTICIDE_UPLOAD_DIR: str = os.path.join(BASE_DIR, "backend", "uploads", "pesticides")
    ENABLE_INVENTORY_BLOCKCHAIN: bool = os.getenv("ENABLE_INVENTORY_BLOCKCHAIN", "true").lower() == "true"
    COMPARISON_SCORE_THRESHOLD: float = float(os.getenv("COMPARISON_SCORE_THRESHOLD", "5.0"))
    SQLALCHEMY_DATABASE_URL: str = os.getenv("DATABASE_URL", f"sqlite:///{os.path.join(BASE_DIR, 'data', 'agriintel.db')}")

    class Config:
        env_file = ".env"
        case_sensitive = True
        extra = "ignore"

settings = Settings()
