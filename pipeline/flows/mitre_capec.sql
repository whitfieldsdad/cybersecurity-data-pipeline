SET preserve_insertion_order = false;

CREATE OR REPLACE TABLE _objects AS (
    SELECT 
        UNNEST("objects") AS o
    FROM read_json_auto(
        '~/src/whitfieldsdad/data/layers/bronze/git/mitre/cti/capec/2.1/stix-capec.json',
        maximum_object_size=4294967295
    )
);

CREATE OR REPLACE TABLE _techniques_to_external_ids AS (
    SELECT
        technique_stix_id,
        ref.external_id,
        ref.source_name,
        ref.url
    FROM (
        SELECT
            o.id AS technique_stix_id,
            UNNEST(o."external_references") AS ref
        FROM _objects
    )
    WHERE ref.source_name IN ('ATTACK', 'capec', 'cwe')
    ORDER BY ref.source_name, ref.external_id
);

CREATE OR REPLACE TABLE _techniques AS (
    SELECT
        stix_id,
        id,
        "name",
        "description",
        consequences
    FROM (
        SELECT
            o.o.id AS stix_id,
            t2e.external_id AS id,
            o.o."name",
            o.o."description",
            o.o."x_capec_consequences" AS consequences
        FROM _objects o
        JOIN _techniques_to_external_ids t2e ON o.o.id = t2e.technique_stix_id
        WHERE t2e.source_name = 'capec' AND o.o.type = 'attack-pattern'
    )
);

CREATE OR REPLACE TABLE _techniques_to_consequences AS (
    SELECT
        stix_id AS technique_stix_id,
        id AS technique_id,
        consequences."Access_Control" AS access_control,
        consequences."Authentication" AS "authentication",
        consequences."Confidentiality" AS confidentiality,
        consequences."Integrity" AS integrity,
        consequences."Availability" AS "availability"
    FROM _techniques
);

CREATE OR REPLACE TABLE techniques_to_consequences AS (
    SELECT
        technique_stix_id,
        technique_id,
        consequence_type,
        consequence
    FROM (
        SELECT
            technique_stix_id,
            technique_id,
            'Access Control' AS consequence_type,
            UNNEST(access_control) AS consequence
        FROM _techniques_to_consequences
        UNION ALL
        SELECT
            technique_stix_id,
            technique_id,
            'Authentication' AS consequence_type,
            UNNEST("authentication") AS consequence
        FROM _techniques_to_consequences
        UNION ALL
        SELECT
            technique_stix_id,
            technique_id,
            'Confidentiality' AS consequence_type,
            UNNEST(confidentiality) AS consequence
        FROM _techniques_to_consequences
        UNION ALL
        SELECT
            technique_stix_id,
            technique_id,
            'Integrity' AS consequence_type,
            UNNEST(integrity) AS consequence
        FROM _techniques_to_consequences
        UNION ALL
        SELECT
            technique_stix_id,
            technique_id,
            'Availability' AS consequence_type,
            UNNEST("availability") AS consequence
        FROM _techniques_to_consequences
    )
    ORDER BY technique_id, consequence_type, consequence
);

CREATE OR REPLACE TABLE techniques AS (
    SELECT 
        stix_id,
        id,
        "name",
        "description"
    FROM _techniques
);

CREATE OR REPLACE TABLE capec_to_cwe AS (
    SELECT
        t.stix_id AS capec_stix_id,
        t.id AS capec_technique_id,
        t2e.external_id AS cwe_weakness_id
    FROM _techniques_to_external_ids t2e
    JOIN techniques t ON t.stix_id = t2e.technique_stix_id
    WHERE t2e.source_name = 'cwe'
    ORDER BY capec_technique_id, cwe_weakness_id
);

CREATE OR REPLACE TABLE capec_to_attack AS (
    SELECT
        t.stix_id AS capec_stix_id,
        t.id AS capec_technique_id,
        t2e.external_id AS attack_technique_id
    FROM _techniques_to_external_ids t2e
    JOIN techniques t ON t.stix_id = t2e.technique_stix_id
    WHERE t2e.source_name = 'ATTACK'
    ORDER BY capec_technique_id, attack_technique_id
);

COPY techniques TO '~/src/whitfieldsdad/data/layers/silver/relational/mitre-capec/techniques.parquet';
COPY techniques_to_consequences TO '~/src/whitfieldsdad/data/layers/silver/relational/mitre-capec/techniques-to-consequences.parquet';
COPY capec_to_cwe TO '~/src/whitfieldsdad/data/layers/silver/relational/mitre-capec/capec-to-cwe.parquet';
COPY capec_to_attack TO '~/src/whitfieldsdad/data/layers/silver/relational/mitre-capec/capec-to-attack.parquet';