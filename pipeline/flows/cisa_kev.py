import json
import os

from metaflow import FlowSpec, step
import requests
from pipeline import util
from pipeline.constants import BRONZE_RAW_DIR, DATA_DIR, SILVER_RELATIONAL_DIR

DIR = os.path.dirname(os.path.abspath(__file__))
J2_FILE = os.path.join(DIR, "cisa_kev.j2")

DOWNLOAD_URL = 'https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json'
DOWNLOAD_PATH = os.path.join(BRONZE_RAW_DIR, 'cisa-kev', 'known_exploited_vulnerabilities.json')


class Flow(FlowSpec):
    @step
    def start(self):
        self.next(self.download_cisa_kev)

    @step
    def download_cisa_kev(self):
        url = DOWNLOAD_URL
        path = DOWNLOAD_PATH
        
        with requests.get(url) as response:
            response.raise_for_status()

            data = response.json()
            os.makedirs(os.path.dirname(path), exist_ok=True)
            with open(path, "w", encoding="utf-8") as f:
                json.dump(data, f, indent=4)
                    
        self.next(self.process_cisa_kev)

    @step
    def process_cisa_kev(self):
        for directory in [SILVER_RELATIONAL_DIR]:
            os.makedirs(os.path.join(directory, 'cisa-kev'), exist_ok=True)

        util.run_sql_template_file(J2_FILE, data_dir=DATA_DIR)

        self.next(self.end)

    @step
    def end(self):
        pass


if __name__ == "__main__":
    Flow()
