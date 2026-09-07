import json
import os

import duckdb
from jinja2 import Template
from metaflow import FlowSpec, step

from pipeline.constants import DATA_DIR, BRONZE_GIT_DIR, SILVER_RELATIONAL_DIR, SILVER_PROCESSED_DIR

DIR = os.path.dirname(os.path.abspath(__file__))
J2_FILE = os.path.join(DIR, "metasploit_framework.j2")

MODULE_METADATA_PATH = os.path.join(BRONZE_GIT_DIR, 'rapid7', 'metasploit-framework', 'db', 'modules_metadata_base.json')
UNPACKED_MODULE_METADATA_PATH = os.path.join(SILVER_PROCESSED_DIR, 'metasploit-framework', 'modules.jsonl')


class Flow(FlowSpec):
    @step
    def start(self):
        self.next(self.unpack)

    @step
    def unpack(self):
        with open(MODULE_METADATA_PATH, "r") as input_file:
            with open(UNPACKED_MODULE_METADATA_PATH, "w") as output_file:
                db = json.load(input_file)
                for module in db.values():
                    output_file.write(json.dumps(module) + "\n")

        self.next(self.process)

    @step
    def process(self):
        for directory in [SILVER_PROCESSED_DIR, SILVER_RELATIONAL_DIR]:
            os.makedirs(os.path.join(directory, 'metasploit-framework'), exist_ok=True)

        with duckdb.connect() as conn:
            with open(J2_FILE, "r") as f:
                template = Template(f.read())
                sql = template.render(
                    data_dir=DATA_DIR,
                )
            conn.execute(sql)

        self.next(self.end)

    @step
    def end(self):
        pass


if __name__ == "__main__":
    Flow()
