import json
from typing import Dict, Any, Optional
from ..blockchain.integrity_ledger import integrity_ledger
from ..core.config import settings

class InventoryBlockchainService:
    @staticmethod
    def record_inventory_added(
        inventory_id: str,
        farmer_id: str,
        product_name: str,
        active_ingredients: list,
        verification_status: str = "VERIFIED_BY_FARMER"
    ) -> Optional[str]:
        if not settings.ENABLE_INVENTORY_BLOCKCHAIN:
            return None

        canonical_payload = {
            "event_type": "PESTICIDE_INVENTORY_ADDED",
            "inventory_id": inventory_id,
            "farmer_id": farmer_id,
            "product_name": product_name,
            "active_ingredients": [
                {
                    "name": ai.get("name") if isinstance(ai, dict) else getattr(ai, "name", str(ai)),
                    "concentration": ai.get("concentration") if isinstance(ai, dict) else getattr(ai, "concentration", "")
                }
                for ai in active_ingredients
            ],
            "verification_status": verification_status
        }

        block = integrity_ledger.add_record(
            record_type="PESTICIDE_INVENTORY_ADDED",
            data_payload=canonical_payload,
            source="AgriIntel Farmer Inventory & CIB&RC Verification",
            verification_status="VERIFIED"
        )
        return block["record_id"]

    @staticmethod
    def record_inventory_updated(
        inventory_id: str,
        farmer_id: str,
        updated_fields: Dict[str, Any]
    ) -> Optional[str]:
        if not settings.ENABLE_INVENTORY_BLOCKCHAIN:
            return None

        clean_fields = {k: v for k, v in updated_fields.items() if k not in ["created_at", "updated_at"]}
        canonical_payload = {
            "event_type": "PESTICIDE_INVENTORY_UPDATED",
            "inventory_id": inventory_id,
            "farmer_id": farmer_id,
            "updated_fields": clean_fields
        }

        block = integrity_ledger.add_record(
            record_type="PESTICIDE_INVENTORY_UPDATED",
            data_payload=canonical_payload,
            source="AgriIntel Farmer Inventory Ledger",
            verification_status="VERIFIED"
        )
        return block["record_id"]

    @staticmethod
    def record_comparison_created(
        comparison_id: str,
        farmer_id: str,
        inventory_pesticide_id: str,
        recommended_pesticide_id: Optional[str],
        crop: str,
        disease: str,
        overall_result: str,
        inventory_score: Optional[float],
        recommended_score: Optional[float]
    ) -> Optional[str]:
        if not settings.ENABLE_INVENTORY_BLOCKCHAIN:
            return None

        canonical_payload = {
            "event_type": "PESTICIDE_COMPARISON_CREATED",
            "comparison_id": comparison_id,
            "farmer_id": farmer_id,
            "inventory_pesticide_id": inventory_pesticide_id,
            "recommended_product_id": recommended_pesticide_id,
            "crop": crop,
            "disease": disease,
            "overall_result": overall_result,
            "inventory_score": inventory_score,
            "recommended_score": recommended_score
        }

        block = integrity_ledger.add_record(
            record_type="PESTICIDE_COMPARISON_CREATED",
            data_payload=canonical_payload,
            source="AgriIntel AHP & Decision Evaluator",
            verification_status="VERIFIED"
        )
        return block["record_id"]

inventory_blockchain_service = InventoryBlockchainService()
