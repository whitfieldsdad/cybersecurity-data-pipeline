import os
import json
from metaflow import FlowSpec, step
from pipeline import util
from pipeline.constants import BRONZE_RAW_DIR, DATA_DIR, JSON_INDENT, SILVER_PROCESSED_DIR
from cwe.json_encoder import JSONEncoder
import cwe.client as cwe

DIR = os.path.dirname(os.path.abspath(__file__))
J2_FILE = os.path.join(DIR, "mitre_cwe.j2")

RAW_CWE_PATH = os.path.join(BRONZE_RAW_DIR, "mitre-cwe/mitre-cwe.xml")
WEAKNESS_CATALOG_PATH = os.path.join(SILVER_PROCESSED_DIR, "mitre-cwe/weaknesses.json")


class Flow(FlowSpec):
    @step
    def start(self):
        self.next(self.download)

    @step
    def download(self):
        os.makedirs(os.path.dirname(RAW_CWE_PATH), exist_ok=True)
        cwe.download(RAW_CWE_PATH)
        self.next(self.parse)

    @step
    def parse(self):
        weakness_catalog = cwe.parse_cwe_xml_file(RAW_CWE_PATH)

        os.makedirs(os.path.dirname(WEAKNESS_CATALOG_PATH), exist_ok=True)
        with open(WEAKNESS_CATALOG_PATH, "w") as f:
            json.dump(weakness_catalog, f, cls=JSONEncoder, indent=JSON_INDENT)
        self.next(self.process)

    @step
    def process(self):
        util.run_sql_template_file(J2_FILE, data_dir=DATA_DIR)

        self.next(self.end)

    @step
    def end(self):
        pass


if __name__ == "__main__":
    Flow()
