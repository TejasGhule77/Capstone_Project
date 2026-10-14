import datetime
from sqlalchemy import (
    Column, String, Float, Integer, Text, Date, DateTime, JSON, ForeignKey
)
from sqlalchemy.orm import relationship
from .session import Base

class PesticideInventory(Base):
    __tablename__ = "pesticide_inventory"

    id = Column(String, primary_key=True)
    farmer_id = Column(String, nullable=False, index=True)
    farm_id = Column(String, nullable=True, index=True)

    product_name = Column(String, nullable=True)
    brand_name = Column(String, nullable=True)
    manufacturer = Column(String, nullable=True)

    formulation = Column(String, nullable=True)
    product_type = Column(String, nullable=True)

    registration_number = Column(String, nullable=True)
    registration_status = Column(String, nullable=False, default="UNKNOWN")

    batch_number = Column(String, nullable=True)
    manufacturing_date = Column(Date, nullable=True)
    expiry_date = Column(Date, nullable=True)

    quantity_value = Column(Float, nullable=True)
    quantity_unit = Column(String, nullable=True)

    target_crops = Column(JSON, nullable=True)
    target_diseases = Column(JSON, nullable=True)

    recommended_dose = Column(String, nullable=True)
    phi_days = Column(Integer, nullable=True)
    mrl_value = Column(String, nullable=True)

    safety_instructions = Column(Text, nullable=True)
    signal_word = Column(String, nullable=True)

    source_type = Column(String, nullable=False, default="FARMER_LABEL")
    verification_status = Column(
        String,
        nullable=False,
        default="PENDING_VERIFICATION"
    )

    ocr_confidence = Column(Float, nullable=True)
    raw_ocr_text = Column(Text, nullable=True)

    front_image_url = Column(String, nullable=True)
    back_image_url = Column(String, nullable=True)
    composition_image_url = Column(String, nullable=True)
    instruction_image_url = Column(String, nullable=True)

    blockchain_record_id = Column(String, nullable=True)

    created_at = Column(DateTime, nullable=False, default=datetime.datetime.utcnow)
    updated_at = Column(DateTime, nullable=False, default=datetime.datetime.utcnow, onupdate=datetime.datetime.utcnow)

    active_ingredients = relationship(
        "InventoryActiveIngredient",
        back_populates="inventory",
        cascade="all, delete-orphan",
        lazy="joined"
    )

class InventoryActiveIngredient(Base):
    __tablename__ = "inventory_active_ingredients"

    id = Column(String, primary_key=True)
    inventory_id = Column(String, ForeignKey("pesticide_inventory.id", ondelete="CASCADE"), nullable=False, index=True)

    ingredient_name = Column(String, nullable=False)
    normalized_name = Column(String, nullable=True)

    concentration_value = Column(Float, nullable=True)
    concentration_unit = Column(String, nullable=True)

    role = Column(String, nullable=True)
    confidence = Column(Float, nullable=True)

    created_at = Column(DateTime, nullable=False, default=datetime.datetime.utcnow)

    inventory = relationship("PesticideInventory", back_populates="active_ingredients")

class PesticideComparison(Base):
    __tablename__ = "pesticide_comparisons"

    id = Column(String, primary_key=True)
    farmer_id = Column(String, nullable=False, index=True)
    inventory_pesticide_id = Column(String, nullable=False)

    recommended_product_id = Column(String, nullable=True)
    crop_id = Column(String, nullable=False)
    disease_id = Column(String, nullable=True)

    inventory_score = Column(Float, nullable=True)
    recommended_score = Column(Float, nullable=True)

    winner_status = Column(String, nullable=False)
    confidence = Column(Float, nullable=True)

    comparison_result = Column(JSON, nullable=False)
    safety_warnings = Column(JSON, nullable=True)

    blockchain_record_id = Column(String, nullable=True)

    created_at = Column(DateTime, nullable=False, default=datetime.datetime.utcnow)
