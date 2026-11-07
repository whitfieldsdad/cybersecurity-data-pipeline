SET preserve_insertion_order = false;

CREATE OR REPLACE TABLE _objects AS (
    SELECT 
        UNNEST("objects") AS o
    FROM read_json_auto(
        '~/src/whitfieldsdad/data/layers/bronze/git/mitre-attack/attack-stix-data/enterprise-attack/enterprise-attack.json',
        maximum_object_size=4294967295
    )
);

-- STIX 2 IDs to ATT&CK IDs
CREATE OR REPLACE TABLE _internal_ids_to_external_ids AS (
    SELECT
        stix_id,
        ref.external_id AS id
    FROM (
        SELECT
            o.id AS stix_id,
            UNNEST(o."external_references") AS ref
        FROM _objects
    )
    WHERE ref.source_name = 'mitre-attack'
);

CREATE OR REPLACE TABLE objects AS (
    SELECT
        o,
        ids.id
    FROM _objects AS o
    LEFT JOIN _internal_ids_to_external_ids AS ids ON o.id = ids.stix_id
    ORDER BY ids.id
);

CREATE OR REPLACE TABLE _relationships AS (
    SELECT
        string_split(o.source_ref, '--')[1] AS source_type,
        o.source_ref,
        o.relationship_type,
        string_split(o.target_ref, '--')[1] AS target_type,
        o.target_ref
    FROM _objects
    WHERE o."type" = 'relationship'
);

CREATE OR REPLACE TABLE tactics AS (
    SELECT 
        o.id AS stix_id,
        id,
        o.name 
    FROM objects
    WHERE o."type" = 'x-mitre-tactic'
);

CREATE OR REPLACE TABLE techniques AS (
    SELECT 
        o.id AS stix_id,
        id,
        o.name 
    FROM objects
    WHERE o."type" = 'attack-pattern'
);

CREATE OR REPLACE TABLE intrusion_sets AS (
    SELECT 
        o.id AS stix_id,
        id,
        o.name,
        o.aliases
    FROM objects
    WHERE o."type" = 'intrusion-set'
);

CREATE OR REPLACE TABLE malware AS (
    SELECT 
        o.id AS stix_id,
        id,
        o.name,
        o.x_mitre_aliases AS aliases,
        o.x_mitre_platforms AS platforms
    FROM objects
    WHERE o."type" = 'malware'
);

CREATE OR REPLACE TABLE tools AS (
    SELECT 
        o.id AS stix_id,
        id,
        o.name,
        o.x_mitre_aliases AS aliases,
        o.x_mitre_platforms AS platforms
    FROM objects
    WHERE o."type" = 'tool'
);

CREATE OR REPLACE TABLE campaigns AS (
    SELECT 
        o.id AS stix_id,
        id,
        o.name,
        o.aliases,
        o.first_seen::TIMESTAMP AS first_seen,
        o.last_seen::TIMESTAMP AS last_seen
    FROM objects
    WHERE o."type" = 'campaign'
);

CREATE OR REPLACE TABLE courses_of_action AS (
    SELECT 
        o.id AS stix_id,
        id,
        o.name 
    FROM objects
    WHERE o."type" = 'course-of-action'
);

CREATE OR REPLACE TABLE detection_strategies AS (
    SELECT 
        o.id AS stix_id,
        id,
        o.name 
    FROM objects
    WHERE o."type" = 'x-mitre-detection-strategy'
);

CREATE OR REPLACE TABLE tactics_to_techniques AS (
    SELECT
        tactic.stix_id AS tactic_stix_id,
        tactic.id AS tactic_id,
        technique.stix_id AS technique_stix_id,
        technique.id AS technique_id
    FROM (
        SELECT
            o.id AS stix_id,
            id,
            UNNEST(o.kill_chain_phases) AS kill_chain_phase
        FROM objects
        WHERE o."type" = 'attack-pattern'
    ) technique
    JOIN (
        SELECT 
            o.id AS stix_id,
            id,
            o.x_mitre_shortname
        FROM objects o
        WHERE o."type" = 'x-mitre-tactic'
    ) tactic ON tactic.x_mitre_shortname = kill_chain_phase.phase_name
    ORDER BY tactic.id, technique.id
);

CREATE OR REPLACE TABLE techniques_to_intrusion_sets AS (
    SELECT
        t.id AS technique_id,
        t.stix_id AS technique_stix_id,
        i.id AS intrusion_set_id,
        i.stix_id AS intrusion_set_stix_id
    FROM _relationships r
    JOIN techniques t ON r.source_ref = t.stix_id
    JOIN intrusion_sets i ON r.target_ref = i.stix_id
    WHERE r.relationship_type = 'uses'
);

CREATE OR REPLACE TABLE techniques_to_courses_of_action AS (
    SELECT
        t.id AS technique_id,
        t.stix_id AS technique_stix_id,
        c.id AS course_of_action_id,
        c.stix_id AS course_of_action_stix_id
    FROM _relationships r
    JOIN techniques t ON r.source_ref = t.stix_id
    JOIN courses_of_action c ON r.target_ref = c.stix_id
    WHERE r.relationship_type = 'mitigates'
);

CREATE OR REPLACE TABLE techniques_to_malware AS (
    SELECT
        t.id AS technique_id,
        t.stix_id AS technique_stix_id,
        m.id AS malware_id,
        m.stix_id AS malware_stix_id
    FROM _relationships r
    JOIN malware m ON r.source_ref = m.stix_id
    JOIN techniques t ON r.target_ref = t.stix_id
    WHERE r.relationship_type = 'uses'
);

CREATE OR REPLACE TABLE techniques_to_tools AS (
    SELECT
        t.id AS technique_id,
        t.stix_id AS technique_stix_id,
        o.id AS tool_id,
        o.stix_id AS tool_stix_id
    FROM _relationships r
    JOIN tools o ON r.source_ref = o.stix_id
    JOIN techniques t ON r.target_ref = t.stix_id
    WHERE r.relationship_type = 'uses'
);

CREATE OR REPLACE TABLE intrusion_sets_to_malware AS (
    SELECT
        i.id AS intrusion_set_id,
        i.stix_id AS intrusion_set_stix_id,
        m.id AS malware_id,
        m.stix_id AS malware_stix_id
    FROM _relationships r
    JOIN intrusion_sets i ON r.source_ref = i.stix_id
    JOIN malware m ON r.target_ref = m.stix_id
    WHERE r.relationship_type = 'uses'
);

CREATE OR REPLACE TABLE intrusion_sets_to_tools AS (
    SELECT
        i.id AS intrusion_set_id,
        i.stix_id AS intrusion_set_stix_id,
        o.id AS tool_id,
        o.stix_id AS tool_stix_id
    FROM _relationships r
    JOIN intrusion_sets i ON r.source_ref = i.stix_id
    JOIN tools o ON r.target_ref = o.stix_id
    WHERE r.relationship_type = 'uses'
);

CREATE OR REPLACE TABLE intrusion_sets_to_techniques AS (
    SELECT
        i.id AS intrusion_set_id,
        i.stix_id AS intrusion_set_stix_id,
        t.id AS technique_id,
        t.stix_id AS technique_stix_id
    FROM _relationships r
    JOIN intrusion_sets i ON r.source_ref = i.stix_id
    JOIN techniques t ON r.target_ref = t.stix_id
    WHERE r.relationship_type = 'uses'
);

CREATE OR REPLACE TABLE campaigns_to_intrusion_sets AS (
    SELECT
        c.id AS campaign_id,
        c.stix_id AS campaign_stix_id,
        i.id AS intrusion_set_id,
        i.stix_id AS intrusion_set_stix_id
    FROM _relationships r
    JOIN campaigns c ON r.source_ref = c.stix_id
    JOIN intrusion_sets i ON r.target_ref = i.stix_id
    WHERE r.relationship_type = 'attributed-to'
);

CREATE OR REPLACE TABLE campaigns_to_techniques AS (
    SELECT
        c.id AS campaign_id,
        c.stix_id AS campaign_stix_id,
        t.id AS technique_id,
        t.stix_id AS technique_stix_id
    FROM _relationships r
    JOIN campaigns c ON r.source_ref = c.stix_id
    JOIN techniques t ON r.target_ref = t.stix_id
    WHERE r.relationship_type = 'uses'
);

CREATE OR REPLACE TABLE campaigns_to_tools AS (
    SELECT
        c.id AS campaign_id,
        c.stix_id AS campaign_stix_id,
        o.id AS tool_id,
        o.stix_id AS tool_stix_id
    FROM _relationships r
    JOIN campaigns c ON r.source_ref = c.stix_id
    JOIN tools o ON r.target_ref = o.stix_id
    WHERE r.relationship_type = 'uses'
);

CREATE OR REPLACE TABLE campaigns_to_malware AS (
    SELECT
        c.id AS campaign_id,
        c.stix_id AS campaign_stix_id,
        m.id AS malware_id,
        m.stix_id AS malware_stix_id
    FROM _relationships r
    JOIN campaigns c ON r.source_ref = c.stix_id
    JOIN malware m ON r.target_ref = m.stix_id
    WHERE r.relationship_type = 'uses'
);

CREATE OR REPLACE TABLE detection_strategies_to_techniques AS (
    SELECT
        d.id AS detection_strategy_id,
        d.stix_id AS detection_strategy_stix_id,
        t.id AS technique_id,
        t.stix_id AS technique_stix_id
    FROM _relationships r
    JOIN detection_strategies d ON r.source_ref = d.stix_id
    JOIN techniques t ON r.target_ref = t.stix_id
    WHERE r.relationship_type = 'detects'
);

COPY tactics TO '~/src/whitfieldsdad/data/layers/silver/relational/mitre-attack/tactics.parquet';
COPY techniques TO '~/src/whitfieldsdad/data/layers/silver/relational/mitre-attack/techniques.parquet';
COPY intrusion_sets TO '~/src/whitfieldsdad/data/layers/silver/relational/mitre-attack/intrusion-sets.parquet';
COPY malware TO '~/src/whitfieldsdad/data/layers/silver/relational/mitre-attack/malware.parquet';
COPY tools TO '~/src/whitfieldsdad/data/layers/silver/relational/mitre-attack/tools.parquet';
COPY campaigns TO '~/src/whitfieldsdad/data/layers/silver/relational/mitre-attack/campaigns.parquet';
COPY courses_of_action TO '~/src/whitfieldsdad/data/layers/silver/relational/mitre-attack/courses-of-action.parquet';
COPY detection_strategies TO '~/src/whitfieldsdad/data/layers/silver/relational/mitre-attack/detection-strategies.parquet';

COPY tactics_to_techniques TO '~/src/whitfieldsdad/data/layers/silver/relational/mitre-attack/tactics-to-techniques.parquet';

COPY techniques_to_intrusion_sets TO '~/src/whitfieldsdad/data/layers/silver/relational/mitre-attack/techniques-to-intrusion-sets.parquet';
COPY techniques_to_courses_of_action TO '~/src/whitfieldsdad/data/layers/silver/relational/mitre-attack/techniques-to-courses-of-action.parquet';
COPY techniques_to_malware TO '~/src/whitfieldsdad/data/layers/silver/relational/mitre-attack/techniques-to-malware.parquet';
COPY techniques_to_tools TO '~/src/whitfieldsdad/data/layers/silver/relational/mitre-attack/techniques-to-tools.parquet';

COPY intrusion_sets_to_malware TO '~/src/whitfieldsdad/data/layers/silver/relational/mitre-attack/intrusion-sets-to-malware.parquet';
COPY intrusion_sets_to_tools TO '~/src/whitfieldsdad/data/layers/silver/relational/mitre-attack/intrusion-sets-to-tools.parquet';
COPY intrusion_sets_to_techniques TO '~/src/whitfieldsdad/data/layers/silver/relational/mitre-attack/intrusion-sets-to-techniques.parquet';

COPY campaigns_to_tools TO '~/src/whitfieldsdad/data/layers/silver/relational/mitre-attack/campaigns-to-tools.parquet';
COPY campaigns_to_malware TO '~/src/whitfieldsdad/data/layers/silver/relational/mitre-attack/campaigns-to-malware.parquet';
COPY campaigns_to_techniques TO '~/src/whitfieldsdad/data/layers/silver/relational/mitre-attack/campaigns-to-techniques.parquet';

COPY detection_strategies_to_techniques TO '~/src/whitfieldsdad/data/layers/silver/relational/mitre-attack/detection-strategies-to-techniques.parquet';
