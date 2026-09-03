SET preserve_insertion_order = false;

CREATE OR REPLACE TABLE modules AS (
    SELECT
        e.key AS "module",
        json_extract_string(e.value, '$.name') AS "name",
        json_extract_string(e.value, '$.description') AS "description",
        json_extract_string(e.value, '$.type') AS "module_type",
        list_transform(json_extract_string(e.value, '$.references[*]'), lambda ref : replace(ref, '''', '')) AS "references"    
    FROM read_json_objects('~/src/whitfieldsdad/data/layers/bronze/git/rapid7/metasploit-framework/db/modules_metadata_base.json') AS source("json")
    CROSS JOIN json_each(source."json") AS e
);

CREATE OR REPLACE TABLE _modules_to_references AS (
    SELECT
        "module",
        module_type,
        ref AS reference
    FROM (
        SELECT
            "name" AS module,
            module_type,
            UNNEST("references") AS ref
        FROM modules
    )
    ORDER BY "module", reference DESC
);

CREATE OR REPLACE TABLE modules_to_cwes AS (
    SELECT
        module,
        module_type,
        reference AS cwe_id
    FROM _modules_to_references
    WHERE reference LIKE 'CWE-%'
);

CREATE OR REPLACE TABLE modules_to_cves AS (
    SELECT
        module,
        module_type,
        reference AS cve_id
    FROM _modules_to_references
    WHERE reference LIKE 'CVE-%'
);

CREATE OR REPLACE TABLE modules_to_attack AS (
    SELECT
        module,
        module_type,
        REPLACE(reference, 'ATT&CK-', '') AS attack_technique_id
    FROM _modules_to_references
    WHERE reference LIKE 'ATT&CK-T1%'
);

COPY modules TO '~/src/whitfieldsdad/data/layers/silver/relational/metasploit-framework/modules.parquet';
COPY modules_to_cves TO '~/src/whitfieldsdad/data/layers/silver/relational/metasploit-framework/modules-to-cves.parquet';
COPY modules_to_cwes TO '~/src/whitfieldsdad/data/layers/silver/relational/metasploit-framework/modules-to-cwes.parquet';
COPY modules_to_attack TO '~/src/whitfieldsdad/data/layers/silver/relational/metasploit-framework/modules-to-attack.parquet';
