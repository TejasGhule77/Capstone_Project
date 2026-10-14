from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from .core.config import settings
import os
from fastapi.staticfiles import StaticFiles
from .routers import auth, crops, weather, crop_doctor, advisory, ahp, integrity, history, chat, pesticide_inventory
from .database.session import init_inventory_db

app = FastAPI(
    title=settings.PROJECT_NAME,
    version=settings.VERSION,
    description="AgriIntel Precision Agro-Intelligence Engine — Production Decision API"
)

# Initialize SQLAlchemy Tables
init_inventory_db()

# Ensure uploads directory exists and mount static route
os.makedirs(settings.PESTICIDE_UPLOAD_DIR, exist_ok=True)
app.mount("/uploads/pesticides", StaticFiles(directory=settings.PESTICIDE_UPLOAD_DIR), name="pesticide_uploads")

# Configure CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Register API Routers with /api prefix
app.include_router(auth.router, prefix=settings.API_V1_STR)
app.include_router(crops.router, prefix=settings.API_V1_STR)
app.include_router(weather.router, prefix=settings.API_V1_STR)
app.include_router(crop_doctor.router, prefix=settings.API_V1_STR)
app.include_router(advisory.router, prefix=settings.API_V1_STR)
app.include_router(ahp.router, prefix=settings.API_V1_STR)
app.include_router(integrity.router, prefix=settings.API_V1_STR)
app.include_router(history.router, prefix=settings.API_V1_STR)
app.include_router(chat.router, prefix=settings.API_V1_STR)
app.include_router(pesticide_inventory.router, prefix=settings.API_V1_STR)

# Register top-level aliases for direct paths (/profile, /crops, /weather, /diagnose, /recommend, /advisories, etc.)
app.include_router(auth.router)
app.include_router(crops.router)
app.include_router(weather.router)
app.include_router(crop_doctor.router)
app.include_router(advisory.router)
app.include_router(ahp.router)
app.include_router(integrity.router)
app.include_router(history.router)
app.include_router(chat.router)
app.include_router(pesticide_inventory.router)

@app.get("/health", tags=["Health"])
def health_check():
    return {
        "status": "healthy",
        "service": settings.PROJECT_NAME,
        "version": settings.VERSION,
        "demo_mode": settings.DEMO_MODE,
        "supported_crops": ["Onion", "Grapes", "Sugarcane", "Wheat"],
        "verification_status": "DEMO"
    }

@app.get("/", tags=["Root"])
def root_endpoint():
    return {
        "message": "Welcome to AgriIntel Precision Agriculture AI Decision API",
        "docs_url": "/docs",
        "health_check": "/health",
        "supported_crops": ["Onion", "Grapes", "Sugarcane", "Wheat"],
        "verification_status": "DEMO"
    }
