SET preserve_insertion_order = false;

CREATE OR REPLACE TABLE _vulnerabilities AS (
    SELECT 
        UNNEST(vulnerabilities) AS o
    FROM '~/src/whitfieldsdad/data/layers/bronze/raw/cisa-kev/known_exploited_vulnerabilities.json'
);

CREATE OR REPLACE TABLE vulnerabilities AS (
    SELECT 
        o.cveId AS cve_id,
        o.vulnerabilityName AS vulnerability_name,
        o.product,
        o.vendorProject AS project,
        o.dateAdded AS date_added,
        o.dueDate AS due_date,
        CASE 
            WHEN o.knownRansomwareCampaignUse = 'Known' THEN true
            WHEN o.knownRansomwareCampaignUse = 'Unknown' THEN false
            ELSE NULL
        END AS known_ransomware_campaign_use
    FROM _vulnerabilities
);

CREATE OR REPLACE TABLE cve_to_cwe AS (
    SELECT
        cve_id,
        cwe_id
    FROM (
        SELECT
            o.cveId AS cve_id,
            UNNEST(o.cwes) AS cwe_id
        FROM _vulnerabilities 
    )
    ORDER BY cve_id, cwe_id
);

COPY vulnerabilities TO '~/src/whitfieldsdad/data/layers/silver/relational/cisa-kev/vulnerabilities.parquet';
COPY cve_to_cwe TO '~/src/whitfieldsdad/data/layers/silver/relational/cisa-kev/cve-to-cwe.parquet';
