from metaflow import FlowSpec, step

import duckdb
import os

from pipeline.constants import SILVER_HIVE_DIR, SILVER_RELATIONAL_DIR, GOLD_ANALYST_DIR

DIR = os.path.dirname(os.path.abspath(__file__))
SQL_FILE = os.path.join(DIR, "epss.sql")


class Flow(FlowSpec):
    @step
    def start(self):
        self.next(self.process_scores)

    @step
    def process_scores(self):
        for directory in [SILVER_HIVE_DIR, SILVER_RELATIONAL_DIR, GOLD_ANALYST_DIR]:
            os.makedirs(os.path.join(directory, 'epss-scores'), exist_ok=True)

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
