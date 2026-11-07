import os

from metaflow import FlowSpec, step
from pipeline import util

from pipeline.constants import DATA_DIR, SILVER_RELATIONAL_DIR, GOLD_ANALYST_DIR

DIR = os.path.dirname(os.path.abspath(__file__))
ETL_A = os.path.join(DIR, "flow-from-bronze-to-silver.sql.j2")
ETL_B = os.path.join(DIR, "flow-from-silver-to-gold.sql.j2")
#ETL_A = os.path.join(DIR, "flow-from-bronze-to-silver.sql")
#ETL_B = os.path.join(DIR, "flow-from-silver-to-gold.sql")


class Flow(FlowSpec):
    @step
    def start(self):
        self.next(self.process)

    @step
    def process(self):
        for directory in [SILVER_RELATIONAL_DIR, GOLD_ANALYST_DIR]:
            os.makedirs(os.path.join(directory, 'mitre-attack'), exist_ok=True)

        for file in [ETL_A, ETL_B]:
            util.run_sql_template_file(file, data_dir=DATA_DIR)
            #util.run_sql_file(file)

        self.next(self.end)

    @step
    def end(self):
        pass


if __name__ == "__main__":
    Flow()
