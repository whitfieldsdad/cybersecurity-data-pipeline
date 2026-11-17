from pipeline import files

import os
import tempfile

GIT_DIR = DATA_PIPELINE_DIR = files.get_project_root()

ENV_FILE_PATH = f'{GIT_DIR}/.env'


def _load_env_file(path: str = None):
    path = path or ENV_FILE_PATH

    with open(path) as f:
        for line in f:
            if line.strip() and not line.startswith('#'):
                key, value = line.strip().split('=', 1)
                os.environ[key] = value


def _check_env():
    for key in ('DATA_DIR',):
        if os.getenv(key) is None:
            raise RuntimeError(f"{key} environment variable is not set")


_load_env_file()
_check_env()

JSON_INDENT = 4

COMPONENT_ID = '79527e84-f8c0-4ee6-97fd-637ae4c4c211'
COMPONENT_TEMP_DIR = os.path.join(tempfile.gettempdir(), COMPONENT_ID)

DATA_DIR = files.get_real_path(os.getenv('DATA_DIR'))

BRONZE_DIR = os.path.join(DATA_DIR, 'layers/bronze')
SILVER_DIR = os.path.join(DATA_DIR, 'layers/silver')
GOLD_DIR = os.path.join(DATA_DIR, 'layers/gold')

BRONZE_GIT_DIR = os.path.join(BRONZE_DIR, 'git')
BRONZE_RAW_DIR = os.path.join(BRONZE_DIR, 'raw')

SILVER_STIX2_DIR = os.path.join(SILVER_DIR, 'stix2')
SILVER_RELATIONAL_DIR = os.path.join(SILVER_DIR, 'relational')
SILVER_PROCESSED_DIR = os.path.join(SILVER_DIR, 'processed')
SILVER_HIVE_DIR = os.path.join(SILVER_DIR, 'hive')

GOLD_ANALYST_DIR = os.path.join(GOLD_DIR, 'analyst')
GOLD_REPORTS_DIR = os.path.join(GOLD_DIR, 'reports')
