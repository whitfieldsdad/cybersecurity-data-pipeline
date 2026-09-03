SET preserve_insertion_order = false;
SET temp_directory = '/tmp/duckdb';

-- EPSS scores
-- * As of 2026-08-30:
--   * 1956 CSV.GZ files
--   * ~432.46 million rows
-- * Includes all historical scores
-- * From 2021-04-14 to 2021-08-31 the `percentile` column is empty
COPY (
    SELECT
        strptime(regexp_extract("filename", 'epss_scores-([0-9]{4}-[0-9]{2}-[0-9]{2})\.csv\.gz$', 1), '%Y-%m-%d')::DATE AS "date",
        cve::VARCHAR AS cve,
        epss::FLOAT AS epss,
        percentile::FLOAT AS percentile
    FROM read_csv(
        '~/src/whitfieldsdad/data/layers/bronze/git/empiricalsec/epss_scores/202*/epss_scores-*-*-*.csv.gz',
        header = true,
        filename = true,
        union_by_name = true,
        comment = '#'
    )
    ORDER BY "date", cve
)
TO '~/src/whitfieldsdad/data/layers/silver/hive/epss-scores'
(
    FORMAT PARQUET,
    PARTITION_BY ("date"),
    OVERWRITE true,
    COMPRESSION ZSTD
);

-- EPSS score changelog
-- * Only includes records where `epss` or `percentile` changed by at least 0.01 since the previous `date`
CREATE OR REPLACE TABLE epss_score_changelog AS
WITH timeline AS (
    SELECT
        "date",
        cve,
        epss,
        percentile,
        lag("date") OVER epss_history AS previous_date,
        lag(epss) OVER epss_history AS previous_epss,
        lag(percentile) OVER epss_history AS previous_percentile,
    FROM read_parquet(
        '~/src/whitfieldsdad/data/layers/silver/hive/epss-scores/*/*.parquet',
        hive_partitioning = true
    )
    WINDOW epss_history AS (PARTITION BY cve ORDER BY "date" ASC)
)
SELECT
    "date",
    cve,
    epss,
    percentile,
    previous_date,
    previous_epss,
    epss - previous_epss AS epss_change,
    100.0 * (epss - previous_epss) / nullif(previous_epss, 0) AS epss_percent_change,
    previous_percentile,
    percentile - previous_percentile AS percentile_change,
    100.0 * (percentile - previous_percentile) / nullif(previous_percentile, 0) AS percentile_percent_change,
FROM timeline
WHERE previous_date IS NULL
   OR abs(epss - previous_epss) >= 0.01
   OR abs(percentile - previous_percentile) >= 0.01
WINDOW epss_history AS (PARTITION BY cve ORDER BY "date" ASC)
ORDER BY "date" ASC, cve ASC;

-- Reduced set of EPSS scores
CREATE OR REPLACE TABLE epss_scores AS (
    SELECT
        "date",
        cve,
        epss,
        percentile
    FROM epss_score_changelog
);

-- EPSS score history
-- * Includes current, min, max `epss` and `percentile` for each CVE
CREATE OR REPLACE TABLE epss_score_history AS
SELECT
    MAX("date") AS "date",
    cve,
    MIN("date") AS earliest_date,
    MIN(epss) AS min_epss,
    MAX(epss) AS max_epss,
    arg_min(epss, "date") AS earliest_epss,
    arg_max(epss, "date") AS epss,
    arg_min(percentile, "date") AS earliest_percentile,
    arg_max(percentile, "date") AS percentile,
    arg_min("date", epss) AS min_epss_date,
    arg_max("date", epss) AS max_epss_date
FROM epss_score_changelog
GROUP BY cve
ORDER BY cve DESC;


COPY epss_scores TO '~/src/whitfieldsdad/data/layers/silver/relational/epss-scores/epss-scores.parquet';
COPY epss_score_changelog TO '~/src/whitfieldsdad/data/layers/silver/relational/epss-scores/epss-score-changelog.parquet';
COPY epss_score_history TO '~/src/whitfieldsdad/data/layers/silver/relational/epss-scores/epss-score-history.parquet';