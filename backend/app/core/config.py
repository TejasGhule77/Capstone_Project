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
    
    class Config:
        env_file = ".env"
        case_sensitive = True
        extra = "ignore"

settings = Settings()
