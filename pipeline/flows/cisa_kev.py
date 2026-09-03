import json
import os

import duckdb
from metaflow import FlowSpec, step
import requests

from pipeline.constants import BRONZE_RAW_DIR, SILVER_RELATIONAL_DIR

DIR = os.path.dirname(os.path.abspath(__file__))
SQL_FILE = os.path.join(DIR, "cisa_kev.sql")

DOWNLOAD_URL = 'https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json'
DOWNLOAD_PATH = os.path.join(BRONZE_RAW_DIR, 'cisa-kev', 'known_exploited_vulnerabilities.json')


class Flow(FlowSpec):
    @step
    def start(self):
        self.next(self.download)

    @step
    def download(self):
        url = DOWNLOAD_URL
        path = DOWNLOAD_PATH
        
        with requests.get(url) as response:
            response.raise_for_status()

            data = response.json()
            os.makedirs(os.path.dirname(path), exist_ok=True)
            with open(path, "w", encoding="utf-8") as f:
                json.dump(data, f, indent=4)
                    
        self.next(self.process)

    @step
    def process(self):
        for directory in [SILVER_RELATIONAL_DIR]:
            os.makedirs(os.path.join(directory, 'cisa-kev'), exist_ok=True)

        with duckdb.connect() as conn:
            with open(SQL_FILE, "r") as f:
                sql = f.read()
            conn.execute(sql)

        self.next(self.end)

    @step
    def end(self):
        pass


if __name__ == "__main__":
    Flow()
