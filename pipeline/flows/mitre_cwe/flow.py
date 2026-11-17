from metaflow import FlowSpec, step
from pipeline.constants import BRONZE_RAW_DIR, SILVER_PROCESSED_DIR

import cwe.client
import os

DIR = os.path.dirname(os.path.abspath(__file__))
J2_FILE = os.path.join(DIR, "etl.sql.j2")

RAW_CWE_PATH = os.path.join(BRONZE_RAW_DIR, "mitre-cwe/weakness-catalog.xml")
PROCESSED_CWE_PATH = os.path.join(SILVER_PROCESSED_DIR, "mitre-cwe/weakness-catalog.json")


class Flow(FlowSpec):
    @step
    def start(self):
        self.next(self.download)

    @step
    def download(self):
        for path in [RAW_CWE_PATH, PROCESSED_CWE_PATH]:
            os.makedirs(os.path.dirname(path), exist_ok=True)

        cwe.client.download_weakness_catalog(RAW_CWE_PATH)
        cwe.client.convert_from_xml_to_json(RAW_CWE_PATH, PROCESSED_CWE_PATH)

        self.next(self.end)


    @step
    def end(self):
        pass


if __name__ == "__main__":
    Flow()
