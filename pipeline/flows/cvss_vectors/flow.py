import os

from metaflow import FlowSpec, step
from pipeline.constants import SILVER_RELATIONAL_DIR
from pipeline import util
from cvss import CVSS2, CVSS3, CVSS4

import polars as pl
import json

# CVEs to CVSS vectors
CVES_TO_CVSS_VECTORS_PATH = f"{SILVER_RELATIONAL_DIR}/mitre-cve/cves-to-cvss-vectors.parquet"

# CVSS vector expansions
CVSS_2_0_VECTORS_PATH = f"{SILVER_RELATIONAL_DIR}/cvss-vectors/cvss-2-0-vectors.parquet"
CVSS_3_0_VECTORS_PATH = f"{SILVER_RELATIONAL_DIR}/cvss-vectors/cvss-3-0-vectors.parquet"
CVSS_3_1_VECTORS_PATH = f"{SILVER_RELATIONAL_DIR}/cvss-vectors/cvss-3-1-vectors.parquet"
CVSS_4_0_VECTORS_PATH = f"{SILVER_RELATIONAL_DIR}/cvss-vectors/cvss-4-0-vectors.parquet"

CVSS_2_0 = 'CVSS 2.0'
CVSS_3_0 = 'CVSS 3.0'
CVSS_3_1 = 'CVSS 3.1'
CVSS_4_0 = 'CVSS 4.0'

PARSERS = {
    CVSS_2_0: CVSS2,
    CVSS_3_0: CVSS3,
    CVSS_3_1: CVSS3,
    CVSS_4_0: CVSS4,
}

REPLACE_NOT_DEFINED_WITH_NULL = True


class Flow(FlowSpec):
    @step
    def start(self):
        self.next(self.expand_vectors)

    @step
    def expand_vectors(self):
        print('Reading CVSS vectors from MITRE CVE')
        cves_to_cvss_vectors = pl.read_parquet(CVES_TO_CVSS_VECTORS_PATH)

        for name, column, output_path in [
            ('CVSS 2.0', "cvss_2_0_vector", CVSS_2_0_VECTORS_PATH),
            ('CVSS 3.0', "cvss_3_0_vector", CVSS_3_0_VECTORS_PATH),
            ('CVSS 3.1', "cvss_3_1_vector", CVSS_3_1_VECTORS_PATH),
            ('CVSS 4.0', "cvss_4_0_vector", CVSS_4_0_VECTORS_PATH),
        ]:
            vectors = set(cves_to_cvss_vectors.get_column(column))
            vectors.discard(None)

            print(f'Expanding {len(vectors)} {name} vectors')
            expanded_vectors = list(map(expand_cvss_vector, vectors))

            os.makedirs(os.path.dirname(output_path), exist_ok=True)
            df = pl.DataFrame(expanded_vectors).to_pandas()

            # Replace any column value of `not-defined` with None
            for col in df.columns:
                df[col] = df[col].replace('not-defined', None)

            df.to_parquet(output_path)

        self.next(self.end)

    @step
    def end(self):
        pass


def expand_cvss_vector(vector: str) -> dict:
    version = get_cvss_version(vector)
    cls = PARSERS[version]

    v = cls(vector)
    o = json.loads(json.dumps(v.as_json()))

    # Convert all keys from camelCase to snake_case, lowercase all strings except for "vector_string", replace '_' with '-'
    raw = {}
    for k, v in o.items():
        k = util.camelcase_to_snake_case(k)
        if isinstance(v, str):
            if k != 'vector_string':
                v = v.lower()
                v = v.replace('_', '-')

        raw[k] = v

    return raw


def get_cvss_version(vector: str) -> str:
    if vector.startswith('CVSS:4.0/'):
        return CVSS_4_0
    elif vector.startswith('CVSS:3.1/'):
        return CVSS_3_1
    elif vector.startswith('CVSS:3.0/'):
        return CVSS_3_0
    else:
        return CVSS_2_0


if __name__ == "__main__":
    Flow()
