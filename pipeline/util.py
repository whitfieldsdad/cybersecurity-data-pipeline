import re

import jinja2
import duckdb


def run_sql_template_file(path: str, **kwargs: dict):
    print(f"Executing SQL file with DuckDB {path}")
    with duckdb.connect() as conn:
        with open(path, "r") as f:
            template = jinja2.Template(f.read())
            sql = template.render(**kwargs)

        conn.execute(sql)


def camelcase_to_snake_case(text: str) -> str:
    return re.sub(r'(?<!^)(?=[A-Z])', '_', text).lower()
