import json
import re
import tempfile
from hodgepodge import spreadsheet_builder

import jinja2
import duckdb

from pipeline.constants import COMPONENT_ID, COMPONENT_TEMP_DIR


def run_sql_file(path: str):
    print(f'Processing SQL file with DuckDB: {path}')
    with duckdb.connect() as conn:
        with open(path, "r") as f:
            sql = f.read()
        conn.execute(sql)


def run_sql_template_file(template_path: str, **kwargs: dict):
    if not template_path.endswith('.j2'):
        raise ValueError("Template filename must end with .j2")

    sql_file_path = template_path[:-3]  # Remove the .j2 extension
    if not sql_file_path.endswith('.sql'):
        raise ValueError("SQL filename must end with .sql")

    print(f'Rendering SQL template: {template_path}')
    with open(template_path, "r") as f:
        template = jinja2.Template(f.read())
        sql = template.render(**kwargs)

    print(f'Generating SQL file: {sql_file_path}')
    with open(sql_file_path, "w") as f:
        f.write(sql)

    run_sql_file(sql_file_path)


def build_workbook_from_template(template_path: str, output_path: str, generate_config: bool = False, **kwargs: dict):
    if not template_path.endswith('.j2'):
        raise ValueError("Workbook config filename must end with .j2")

    config_path = template_path[:-3]
    if not config_path.endswith('.json'):
        raise ValueError("Workbook config filename must end with .json after removing .j2")

    print(f'Rendering workbook template: {template_path}')
    with open(template_path, "r") as fp:
        data = fp.read()
        template = jinja2.Template(data)
        data = template.render(**kwargs)

    if generate_config:
        print(f'Generating workbook config file: {config_path}')
        with open(config_path, "w") as fp:
            fp.write(data)

        build_workbook(config_path, output_path)
    else:
        with tempfile.NamedTemporaryFile(suffix='.json', delete=False) as tmp:
            tmp.write(data.encode('utf-8'))
            tmp.flush()
            build_workbook(tmp.name, output_path)


def build_workbook(config_path: str, output_path: str):
    print(f'Building workbook: {output_path}')
    
    with open(config_path, "r") as fp:
        data = fp.read()
    
    config = spreadsheet_builder.parse_workbook_config(json.loads(data))
    spreadsheet_builder.build_workbook(config, output_path)


def camelcase_to_snake_case(text: str) -> str:
    return re.sub(r'(?<!^)(?=[A-Z])', '_', text).lower()
