import re

import duckdb


def run_duckdb_sql_file(path: str):
    print(f"Executing SQL file with DuckDB {path}")
    with duckdb.connect() as conn:
        with open(path, "r") as f:
            sql = f.read()
        conn.execute(sql)


def camelcase_to_snake_case(text: str) -> str:
    return re.sub(r'(?<!^)(?=[A-Z])', '_', text).lower()
