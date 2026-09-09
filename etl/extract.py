import os
import csv
import logging
from typing import List, Dict, Any

logger = logging.getLogger(__name__)

class DataExtractor:
    def __init__(self, data_dir: str):
        self.data_dir = data_dir

    def extract_csv(self, filename: str) -> List[Dict[str, Any]]:
        path = os.path.join(self.data_dir, filename)
        if not os.path.exists(path):
            logger.warning(f"File not found for extraction: {path}")
            return []
        
        records = []
        with open(path, mode="r", encoding="utf-8") as f:
            reader = csv.DictReader(f)
            for row in reader:
                records.append(dict(row))
        return records
