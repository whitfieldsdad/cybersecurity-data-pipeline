import json
import re
from hodgepodge import spreadsheet_builder

import jinja2
import duckdb


def run_sql_template_file(path: str, **kwargs: dict):
    print(f"Executing SQL file with DuckDB {path}")
    with duckdb.connect() as conn:
        with open(path, "r") as f:
            template = jinja2.Template(f.read())
            sql = template.render(**kwargs)

        conn.execute(sql)


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
