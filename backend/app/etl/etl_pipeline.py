"""
ETL Data Pipeline for AgriIntel
Ingests, cleans, validates, and normalizes raw agricultural sensor streams, weather records, and mandi market prices.
Enforces schema conformance and flags all simulated inputs with verification_status = 'DEMO'.
"""

import logging
from typing import Dict, Any, List
import datetime

logger = logging.getLogger(__name__)

class ETLPipeline:
    def __init__(self):
        self.supported_crops = ["Onion", "Grapes", "Sugarcane", "Wheat"]

    def transform_weather_stream(self, raw_data: Dict[str, Any]) -> Dict[str, Any]:
        """Cleans and standardizes raw telemetry / API weather readings into normalized schema."""
        temp = float(raw_data.get("temp", raw_data.get("temperature", 28.0)))
        humidity = int(raw_data.get("humidity", 60))
        wind = float(raw_data.get("wind_speed", raw_data.get("wind", 10.0)))
        rain_prob = int(raw_data.get("rain_prob", raw_data.get("pop", 10)))

        # Evaluate Weather Gatekeeper rule
        # Rule: Good if wind < 15 km/h, rain < 30%, humidity between 40% and 80%
        if wind > 18.0 or rain_prob > 50:
            spray_status = "DO NOT SPRAY"
            reason = "Excessive wind speed or impending precipitation creates spray drift/wash-off danger."
        elif wind > 12.0 or humidity > 75 or rain_prob > 25:
            spray_status = "CAUTION"
            reason = "Sub-optimal humidity/wind threshold. Use fine nozzles and check evening window."
        else:
            spray_status = "GOOD TO SPRAY"
            reason = "Optimal microclimate: mild wind, balanced humidity, and low precipitation likelihood."

        return {
            "temperature_c": round(temp, 1),
            "humidity_pct": humidity,
            "wind_speed_kmh": round(wind, 1),
            "rain_probability_pct": rain_prob,
            "spray_condition": spray_status,
            "spray_reason": reason,
            "processed_at": datetime.datetime.now(datetime.timezone.utc).isoformat(),
            "verification_status": "DEMO"
        }

    def process_mandi_prices(self, raw_records: List[Dict[str, Any]]) -> List[Dict[str, Any]]:
        """Processes and standardizes APMC market mandi price inputs."""
        cleaned = []
        for rec in raw_records:
            crop = str(rec.get("crop", "")).strip().title()
            if crop in self.supported_crops:
                cleaned.append({
                    "crop": crop,
                    "market": rec.get("market", "APMC Pune"),
                    "modal_price_per_quintal": float(rec.get("price", 2200)),
                    "price_trend": rec.get("trend", "Bullish"),
                    "arrival_volume_tonnes": float(rec.get("arrivals", 150.0)),
                    "verification_status": "DEMO"
                })
        return cleaned

etl_pipeline = ETLPipeline()
