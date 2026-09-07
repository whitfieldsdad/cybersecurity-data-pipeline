from jinja2 import Template
from metaflow import FlowSpec, step

import duckdb
import os

from pipeline.constants import DATA_DIR, SILVER_HIVE_DIR, SILVER_RELATIONAL_DIR, GOLD_ANALYST_DIR

DIR = os.path.dirname(os.path.abspath(__file__))
J2_FILE = os.path.join(DIR, "epss.j2")


class Flow(FlowSpec):
    @step
    def start(self):
        self.next(self.process_scores)

    @step
    def process_scores(self):
        for directory in [SILVER_HIVE_DIR, SILVER_RELATIONAL_DIR, GOLD_ANALYST_DIR]:
            os.makedirs(os.path.join(directory, 'epss-scores'), exist_ok=True)

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
