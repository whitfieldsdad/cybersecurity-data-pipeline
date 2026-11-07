import json
import os
import re
import tempfile
from hodgepodge import spreadsheet_builder

import jinja2
import duckdb

from pipeline.constants import COMPONENT_ID, COMPONENT_TEMP_DIR


def run_sql_file(path: str):
    with duckdb.connect() as conn:
        with open(path, "r") as f:
            sql = f.read()
        conn.execute(sql)


def run_sql_template_file(path: str, **kwargs: dict):
    with open(path, "r") as f:
        template = jinja2.Template(f.read())
        sql = template.render(**kwargs)

    os.makedirs(COMPONENT_TEMP_DIR, exist_ok=True)
    with tempfile.NamedTemporaryFile(dir=COMPONENT_TEMP_DIR, mode="w+", suffix=".sql", delete=True) as tmp:
        tmp.write(sql)
        tmp.flush()
        run_sql_file(tmp.name)


def build_workbook(config_path: str, output_path: str, **kwargs: dict):
    print(f'Building workbook from config file: {config_path}')

    with open(config_path, "r") as fp:
        data = fp.read()
        if config_path.endswith('.j2'):
            template = jinja2.Template(data)
            data = template.render(**kwargs)

    config = spreadsheet_builder.parse_workbook_config(json.loads(data))
    spreadsheet_builder.build_workbook(config, output_path)

def camelcase_to_snake_case(text: str) -> str:
    return re.sub(r'(?<!^)(?=[A-Z])', '_', text).lower()
