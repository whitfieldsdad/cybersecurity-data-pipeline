import os

import duckdb
from jinja2 import Template
from metaflow import FlowSpec, step

from pipeline.constants import DATA_DIR, SILVER_RELATIONAL_DIR

DIR = os.path.dirname(os.path.abspath(__file__))
SQL_FILE = os.path.join(DIR, "mitre_attack.sql")


class Flow(FlowSpec):
    @step
    def start(self):
        self.next(self.process)

    @step
    def process(self):
        for directory in [SILVER_RELATIONAL_DIR]:
            os.makedirs(os.path.join(directory, 'mitre-attack'), exist_ok=True)

        with duckdb.connect() as conn:
            with open(SQL_FILE, "r") as f:
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
