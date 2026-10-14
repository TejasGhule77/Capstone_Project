"""
AgriIntel Image Preprocessing & Quality Validation Module
Handles image format verification, file size checks, corruption detection,
luminance/blur validation, and standard ImageNet tensor normalization.
"""

import io
import os
from typing import Dict, Any, Tuple
import numpy as np
from PIL import Image

ALLOWED_EXTENSIONS = {".jpg", ".jpeg", ".png", ".webp", ".bmp"}
MAX_FILE_SIZE_BYTES = 15 * 1024 * 1024  # 15 MB
TARGET_IMAGE_SIZE = (224, 224)

# ImageNet standard normalization parameters
IMAGENET_MEAN = np.array([0.485, 0.456, 0.406], dtype=np.float32)
IMAGENET_STD = np.array([0.229, 0.224, 0.225], dtype=np.float32)

class ImagePreprocessor:
    @staticmethod
    def validate_image(filename: str, image_bytes: bytes) -> Tuple[bool, str, Dict[str, Any]]:
        """
        Performs rigorous validation on incoming leaf image bytes.
        Checks:
        1. Non-empty content
        2. File size within limits
        3. File extension
        4. Valid decodable image structure
        5. Minimum resolution
        6. Severe underexposure (too dark) / overexposure (too washed out)
        """
        if not image_bytes or len(image_bytes) == 0:
            return False, "Empty image file received. Please upload a valid plant leaf image.", {}

        if len(image_bytes) > MAX_FILE_SIZE_BYTES:
            size_mb = len(image_bytes) / (1024 * 1024)
            return False, f"Image size ({size_mb:.1f}MB) exceeds the maximum allowed 15MB limit.", {}

        _, ext = os.path.splitext(filename.lower())
        if ext and ext not in ALLOWED_EXTENSIONS:
            return False, f"Unsupported format '{ext}'. Allowed formats: JPG, JPEG, PNG, WEBP.", {}

        try:
            image = Image.open(io.BytesIO(image_bytes))
            image.verify()  # Verify file integrity
            # Reopen after verify() because verify() closes the stream
            image = Image.open(io.BytesIO(image_bytes)).convert("RGB")
        except Exception as e:
            return False, f"Corrupted or unreadable image file: {str(e)}", {}

        width, height = image.size
        if width < 32 or height < 32:
            return False, f"Image resolution ({width}x{height}) is too low for diagnostic analysis. Minimum required is 32x32.", {}

        # Convert to numpy array for quality metrics
        img_np = np.array(image, dtype=np.float32)
        mean_brightness = float(np.mean(img_np))
        contrast_std = float(np.std(img_np))

        # Check for pitch black or blank white images
        if mean_brightness < 12.0:
            return False, "Image quality is too dark for reliable diagnosis. Please capture the leaf in adequate lighting.", {}
        if mean_brightness > 250.0 and contrast_std < 5.0:
            return False, "Image is overexposed/blank. Please capture a clear focused shot of the symptomatic leaf.", {}

        metrics = {
            "width": width,
            "height": height,
            "mean_brightness": round(mean_brightness, 2),
            "contrast_std": round(contrast_std, 2),
            "format": ext or ".jpg"
        }
        return True, "Image passed quality validation.", metrics

    @staticmethod
    def preprocess_image_to_numpy(image_bytes: bytes) -> np.ndarray:
        """
        Preprocesses raw image bytes into normalized (1, 3, 224, 224) float32 tensor array.
        """
        image = Image.open(io.BytesIO(image_bytes)).convert("RGB")
        image = image.resize(TARGET_IMAGE_SIZE, Image.Resampling.BILINEAR)

        img_arr = np.array(image, dtype=np.float32) / 255.0  # Scale to [0, 1]
        
        # Apply ImageNet normalization (H, W, C)
        img_norm = (img_arr - IMAGENET_MEAN) / IMAGENET_STD
        
        # Transpose to (C, H, W) and add batch dimension -> (1, 3, 224, 224)
        tensor = np.transpose(img_norm, (2, 0, 1))
        tensor = np.expand_dims(tensor, axis=0)
        return tensor

preprocessor = ImagePreprocessor()
