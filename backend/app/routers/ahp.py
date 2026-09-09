from fastapi import APIRouter
from ..models.schemas import (
    AHPEvaluateRequest, AHPResponse, RecommendationRequest, RecommendationResponse
)
from ..ahp.ahp_engine import ahp_engine
from ..blockchain.integrity_ledger import integrity_ledger

router = APIRouter(tags=["AHP Multi-Criteria Decision & Pesticide Recommendations"])

@router.post("/ahp/evaluate", response_model=AHPResponse)
def evaluate_crop_planning(req: AHPEvaluateRequest):
    """
    Executes Analytic Hierarchy Process (AHP) matrix evaluation for crop planning.
    Computes priority weights, Consistency Ratio (CR < 0.10), and rankings for Onion, Grapes, Sugarcane, Wheat.
    """
    results = ahp_engine.evaluate_crops(
        district=req.district,
        soil_type=req.soil_type,
        irrigation=req.irrigation_available
    )
    return AHPResponse(**results)

@router.post("/recommend", response_model=RecommendationResponse)
@router.post("/ahp/recommend", response_model=RecommendationResponse)
def get_pesticide_recommendations(req: RecommendationRequest):
    """
    Runs AHP multi-criteria ranking for verified pesticide candidates.
    Applies Weather Gatekeeper safety priority override.
    """
    results = ahp_engine.rank_pesticide_recommendations(
        crop=req.crop,
        disease=req.disease,
        severity=req.severity,
        weather=req.weather,
        crop_stage=req.crop_stage
    )

    # Log recommendation to Blockchain Ledger
    integrity_ledger.add_record(
        record_type="RECOMMENDATION",
        data_payload={
            "crop": results["crop"],
            "disease": results["disease"],
            "top_candidate": results["ranking"][0]["product_name"] if results["ranking"] else "N/A",
            "top_ahp_score": results["ranking"][0]["ahp_score"] if results["ranking"] else 0.0,
            "gatekeeper_status": results["weather_gatekeeper_status"]
        },
        source="AgriIntel AHP Engine & CIB&RC Registry",
        verification_status="VERIFIED"
    )

    return RecommendationResponse(**results)
