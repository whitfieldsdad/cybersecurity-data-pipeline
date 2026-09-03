import os

from pipeline import files

DATA_PIPELINE_DIR = files.get_project_root()
DATA_DIR = files.get_real_path('~/src/whitfieldsdad/data')

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

JSON_INDENT = 4
