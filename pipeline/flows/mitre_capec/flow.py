import os

from pipeline import util
from metaflow import step
from pipeline.flows.base.flow import BaseFlow

from pipeline.constants import DATA_DIR, SILVER_RELATIONAL_DIR

DIR = os.path.dirname(os.path.abspath(__file__))
J2_FILE = os.path.join(DIR, "etl.sql.j2")


class Flow(BaseFlow):
    @step
    def start(self):
        self.next(self.process)

    @step
    def process(self):
        for directory in [SILVER_RELATIONAL_DIR]:
            os.makedirs(os.path.join(directory, 'mitre-capec'), exist_ok=True)

        util.run_sql_template_file(J2_FILE, data_dir=DATA_DIR)

        self.next(self.end)

    @step
    def end(self):
        pass


if __name__ == "__main__":
    Flow()
