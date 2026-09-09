from fastapi import APIRouter
from ..models.schemas import ChatMessageRequest, ChatMessageResponse

router = APIRouter(tags=["AI Agronomy Assistant Chat"])

@router.post("/chat", response_model=ChatMessageResponse)
def chat_with_agri_expert(req: ChatMessageRequest):
    """Provides conversational agronomy advisory for Onion, Grapes, Sugarcane, and Wheat."""
    query = req.message.lower()
    crop = req.crop or "Grapes"

    if "downy" in query or "mildew" in query:
        reply = (
            f"For Downy Mildew in {crop}, ensure foliage is aerated. "
            "If humidity is above 80%, spray Potassium Phosphonate @ 3g/L or Dimethomorph 50% WP @ 1g/L. "
            "Always verify with the Weather Gatekeeper before application."
        )
        actions = ["Check Weather Gatekeeper", "View AHP Pesticide Ranking", "Scan Leaf Sample"]
    elif "spray" in query or "weather" in query:
        reply = (
            "Before spraying, ensure wind speed is under 12 km/h and rain probability is below 20%. "
            "Early morning hours (06:30 AM to 09:30 AM) provide the ideal microclimate spray window."
        )
        actions = ["Open Weather Screen", "Run Spray Check", "View Active Advisories"]
    elif "fertilizer" in query or "dose" in query:
        reply = (
            f"For {crop}, balanced NPK with secondary micronutrients (Zinc, Boron, Magnesium) "
            "is essential during vegetative expansion. Follow state university fertilizer schedules."
        )
        actions = ["View Crop Stages", "Check Soil Parameters", "Ask Another Question"]
    else:
        reply = (
            f"Welcome to AgriIntel AI Agronomy Assistant. How can I assist you today with {crop}? "
            "You can ask about disease diagnosis, spray timing, weather suitability, or verified pesticides."
        )
        actions = ["Scan Crop Leaf", "Check Spray Gatekeeper", "View AHP Recommendations"]

    return ChatMessageResponse(
        reply=reply,
        suggested_actions=actions,
        verification_status="DEMO"
    )
