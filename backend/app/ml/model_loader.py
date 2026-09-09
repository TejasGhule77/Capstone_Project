"""
AgriIntel Model Loader
Loads PyTorch ResNet-18 plant disease model weights as a singleton.
"""

import os
import logging
from typing import Optional, Any
from ..core.config import settings

logger = logging.getLogger("AgriIntel-ModelLoader")

class PlantDiseaseModelLoader:
    _instance = None
    _model = None
    _is_loaded = False
    _model_path = None

    def __new__(cls):
        if cls._instance is None:
            cls._instance = super(PlantDiseaseModelLoader, cls).__new__(cls)
        return cls._instance

    def __init__(self):
        if not self._is_loaded:
            self._init_model()

    def _find_model_file(self) -> Optional[str]:
        candidates = [
            os.path.join(settings.BASE_DIR, "AgriIntel", "models", "plant_disease", "plant_disease_model.pth"),
            os.path.join(settings.BASE_DIR, "AgriIntel", "Agri", "plant_disease", "plant_disease_model.pth"),
            os.path.join(settings.BASE_DIR, "models", "crop_doctor", "plant_disease_model.pth"),
            os.path.join(settings.BASE_DIR, "models", "plant_disease_model.pth"),
        ]
        for p in candidates:
            if os.path.exists(p):
                return p
        return None

    def _init_model(self):
        model_path = self._find_model_file()
        if not model_path:
            logger.warning("PyTorch model file not found in candidates. Falling back to calibrated inference mode.")
            self._is_loaded = False
            return

        self._model_path = model_path
        try:
            import torch
            import torch.nn as nn
            from torchvision.models import resnet18

            logger.info(f"Loading PyTorch ResNet-18 weights from {model_path}...")
            state_dict = torch.load(model_path, map_location=torch.device("cpu"))
            
            # Determine num_classes from checkpoint
            num_classes = 38
            if "fc.weight" in state_dict:
                num_classes = state_dict["fc.weight"].shape[0]
            elif "classifier.weight" in state_dict:
                num_classes = state_dict["classifier.weight"].shape[0]

            model = resnet18(weights=None)
            model.fc = nn.Linear(model.fc.in_features, num_classes)
            model.load_state_dict(state_dict)
            model.eval()
            
            self._model = model
            self._is_loaded = True
            logger.info(f"Plant Disease Model (classes={num_classes}) successfully initialized and cached in memory.")
        except Exception as e:
            logger.warning(f"Failed to load PyTorch model: {e}. Model loader will operate in hybrid inference mode.")
            self._model = None
            self._is_loaded = False

    @property
    def is_loaded(self) -> bool:
        return self._is_loaded

    @property
    def model(self) -> Any:
        return self._model

    @property
    def model_path(self) -> Optional[str]:
        return self._model_path

model_loader = PlantDiseaseModelLoader()
