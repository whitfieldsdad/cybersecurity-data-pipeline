import json
import os

from metaflow import step
from pipeline.flows.base.flow import BaseFlow
from pipeline import util

from pipeline.constants import DATA_DIR, BRONZE_GIT_DIR, SILVER_PROCESSED_DIR, SILVER_RELATIONAL_DIR

DIR = os.path.dirname(os.path.abspath(__file__))
J2_FILE = os.path.join(DIR, "etl.sql.j2")

MODULE_METADATA_PATH = os.path.join(BRONZE_GIT_DIR, 'rapid7', 'metasploit-framework', 'db', 'modules_metadata_base.json')
UNPACKED_MODULE_METADATA_PATH = os.path.join(SILVER_PROCESSED_DIR, 'metasploit-framework', 'modules.jsonl')


class Flow(BaseFlow):
    @step
    def start(self):
        self.next(self.unpack)

    @step
    def unpack(self):
        for directory in [BRONZE_GIT_DIR, SILVER_PROCESSED_DIR, SILVER_RELATIONAL_DIR]:
            subdirectory = os.path.join(directory, 'metasploit-framework')
            os.makedirs(subdirectory, exist_ok=True)
        
        with open(MODULE_METADATA_PATH, "r") as input_file:
            with open(UNPACKED_MODULE_METADATA_PATH, "w") as output_file:
                db = json.load(input_file)
                for module in db.values():
                    output_file.write(json.dumps(module) + "\n")

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
