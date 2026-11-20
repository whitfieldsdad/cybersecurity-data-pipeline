import os

from metaflow import step
from pipeline.flows.base.flow import BaseFlow
from pipeline import util

import glob

from pipeline.constants import DATA_DIR, SILVER_RELATIONAL_DIR, GOLD_ANALYST_DIR

DIR = os.path.dirname(os.path.abspath(__file__))

ETL_A = os.path.join(DIR, "flow-from-bronze-to-silver.sql.j2")
ETL_B = os.path.join(DIR, "flow-from-silver-to-gold.sql.j2")

WORKBOOKS_DIR = os.path.join(DIR, "workbooks")
WORKBOOK_TEMPLATES = glob.glob(os.path.join(WORKBOOKS_DIR, '*.json.j2'))


class Flow(BaseFlow):
    @step
    def start(self):
        self.next(self.process)

    @step
    def process(self):
        for directory in [SILVER_RELATIONAL_DIR, GOLD_ANALYST_DIR]:
            os.makedirs(os.path.join(directory, 'mitre-attack'), exist_ok=True)

        for file in [ETL_A, ETL_B]:
            util.run_sql_template_file(file, data_dir=DATA_DIR)

        self.next(self.build_workbooks)
    
    @step
    def build_workbooks(self):
        output_dir = os.path.join(GOLD_ANALYST_DIR, 'mitre-attack')
        for input_path in WORKBOOK_TEMPLATES:
            output_path = os.path.join(output_dir, os.path.basename(input_path).replace('.json.j2', '.xlsx'))
            util.build_workbook_from_template(
                template_path=input_path,
                output_path=output_path,
                generate_config=False,
                data_dir=DATA_DIR
            )

        self.next(self.end)

    @step
    def end(self):
        pass


if __name__ == "__main__":
    Flow()
