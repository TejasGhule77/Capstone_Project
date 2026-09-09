import os
import csv
import logging
from typing import List, Dict, Any

logger = logging.getLogger(__name__)

class DataLoader:
    def __init__(self, data_dir: str):
        self.data_dir = data_dir

    def save_csv(self, filename: str, records: List[Dict[str, Any]]) -> str:
        if not records:
            logger.warning(f"No records to save for {filename}")
            return ""

        path = os.path.join(self.data_dir, filename)
        fieldnames = list(records[0].keys())

        with open(path, mode="w", newline="", encoding="utf-8") as f:
            writer = csv.DictWriter(f, fieldnames=fieldnames)
            writer.writeheader()
            writer.writerows(records)

        logger.info(f"Successfully saved {len(records)} records to {path}")
        return path
