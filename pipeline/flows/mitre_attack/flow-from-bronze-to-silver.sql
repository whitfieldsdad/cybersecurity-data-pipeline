SET preserve_insertion_order = false;

CREATE OR REPLACE TABLE __objects AS (
    SELECT
        *
    FROM (
        SELECT 
            UNNEST("objects") AS o
        FROM read_json_auto(
            '/home/tyler/src/whitfieldsdad/data/layers/bronze/git/mitre-attack/attack-stix-data/enterprise-attack/enterprise-attack.json',
            maximum_object_size=4294967295
        )
    )
    WHERE COALESCE(o.x_mitre_deprecated, o.revoked) != true
);

-- STIX 2 IDs to ATT&CK IDs
CREATE OR REPLACE TABLE stix_ids_to_external_ids AS (
    SELECT
        stix_id,
        ref.external_id AS external_id,
        "type",
        "name"
    FROM (
        SELECT
            o.id AS stix_id,
            o.type,
            o.name,
            UNNEST(o."external_references") AS ref
        FROM __objects
    )
    WHERE ref.source_name = 'mitre-attack'
    ORDER BY "type", external_id
);

CREATE OR REPLACE TABLE _objects AS (
    SELECT
        o,
        ids.external_id AS id
    FROM __objects AS o
    LEFT JOIN stix_ids_to_external_ids AS ids ON o.id = ids.stix_id
    ORDER BY ids.external_id
);

CREATE OR REPLACE TABLE _relationships AS (
    SELECT
        string_split(o.source_ref, '--')[1] AS source_type,
        o.source_ref,
        o.relationship_type,
        string_split(o.target_ref, '--')[1] AS target_type,
        o.target_ref,
        o.description
    FROM __objects
    WHERE o."type" = 'relationship'
);

-- Relationships
CREATE OR REPLACE TABLE relationships AS (
    SELECT
        source_ref AS source_stix_id,
        (SELECT external_id FROM stix_ids_to_external_ids WHERE stix_id = source_ref) AS source_external_id,
        source_type,
        relationship_type,
        target_type,
        target_ref AS target_stix_id,
        (SELECT external_id FROM stix_ids_to_external_ids WHERE stix_id = target_ref) AS target_external_id,
        "description"
    FROM _relationships
    ORDER BY source_type, source_external_id, relationship_type, target_type, target_external_id
);

-- Tactics
CREATE OR REPLACE TABLE tactics AS (
    SELECT 
        o.id AS stix_id,
        id,
        o.name,
        o.description
    FROM _objects
    WHERE o."type" = 'x-mitre-tactic'
);

-- Techniques
CREATE OR REPLACE TABLE techniques AS (
    SELECT 
        o.id AS stix_id,
        id,
        o.name,
        o.x_mitre_platforms AS platforms
    FROM _objects
    WHERE o."type" = 'attack-pattern'
);

-- Intrusion sets
CREATE OR REPLACE TABLE intrusion_sets AS (
    SELECT 
        o.id AS stix_id,
        id,
        o.name,
        o.aliases
    FROM _objects
    WHERE o."type" = 'intrusion-set'
);

-- Malware
CREATE OR REPLACE TABLE malware AS (
    SELECT 
        o.id AS stix_id,
        id,
        o.name,
        o.description,
        o.x_mitre_aliases AS aliases,
        o.x_mitre_platforms AS platforms,
        o.is_family,
    FROM _objects
    WHERE o."type" = 'malware'
);

-- Tools
CREATE OR REPLACE TABLE tools AS (
    SELECT 
        o.id AS stix_id,
        id,
        o.name,
        o.description,
        o.x_mitre_aliases AS aliases,
        o.x_mitre_platforms AS platforms
    FROM _objects
    WHERE o."type" = 'tool'
);

-- Campaigns
CREATE OR REPLACE TABLE campaigns AS (
    SELECT 
        o.id AS stix_id,
        id,
        o.name,
        o.description,
        o.aliases,
        o.first_seen::TIMESTAMP AS first_seen,
        o.last_seen::TIMESTAMP AS last_seen
    FROM _objects
    WHERE o."type" = 'campaign'
);

-- Courses of action 
CREATE OR REPLACE TABLE courses_of_action AS (
    SELECT 
        o.id AS stix_id,
        id,
        o.name,
        o.description
    FROM _objects
    WHERE o."type" = 'course-of-action'
);

-- Detection strategies
CREATE OR REPLACE TABLE detection_strategies AS (
    SELECT 
        o.id AS stix_id,
        id,
        o.name 
    FROM _objects
    WHERE o."type" = 'x-mitre-detection-strategy'
);

-- Detection strategies to analytics
CREATE OR REPLACE TABLE detection_strategies_to_analytics AS (
    SELECT
        id AS detection_strategy_id,
        o.id AS detection_strategy_stix_id,
        UNNEST(o.x_mitre_analytic_refs) AS analytic_stix_id
    FROM _objects
    WHERE o."type" = 'x-mitre-detection-strategy'
);

-- Analytics
-- * TODO: parse `x_mitre_mutable_elements`
CREATE OR REPLACE TABLE analytics AS (
    SELECT 
        o.id AS stix_id,
        id,
        o.name,
        o.description,
        o.x_mitre_platforms AS platforms
    FROM _objects
    WHERE o."type" = 'x-mitre-analytic'
);

-- Analytics to log sources
CREATE OR REPLACE TABLE analytics_to_log_sources AS (
    SELECT
        analytic_stix_id,
        analytic_id,
        data_component.x_mitre_data_component_ref AS data_component_stix_id,
        data_component.name AS "name",
        data_component.channel AS channel
    FROM (
        SELECT
            o.id AS analytic_stix_id,
            id AS analytic_id,
            UNNEST(o.x_mitre_log_source_references) AS data_component
        FROM _objects o
        WHERE o."type" = 'x-mitre-analytic'
    )
);

-- Log sources
CREATE OR REPLACE TABLE log_sources AS (
    SELECT
        data_component_stix_id,
        "name",
        channel
    FROM analytics_to_log_sources
    GROUP BY *
    ORDER BY "name", channel
);

-- Data components
CREATE OR REPLACE TABLE data_components AS (
    SELECT 
        o.id AS stix_id,
        id,
        o.name 
    FROM _objects
    WHERE o."type" = 'x-mitre-data-component'
);

-- Data sources
CREATE OR REPLACE TABLE data_sources AS (
    SELECT 
        o.id AS stix_id,
        id,
        o.name 
    FROM _objects
    WHERE o."type" = 'x-mitre-data-source'
);

-- Tactics to techniques
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
        FROM _objects
        WHERE o."type" = 'attack-pattern'
    ) technique
    JOIN (
        SELECT 
            o.id AS stix_id,
            id,
            o.x_mitre_shortname
        FROM _objects o
        WHERE o."type" = 'x-mitre-tactic'
    ) tactic ON tactic.x_mitre_shortname = kill_chain_phase.phase_name
    ORDER BY tactic.id, technique.id
);

-- Techniques to intrusion sets
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

-- Techniques to courses of action
CREATE OR REPLACE TABLE techniques_to_courses_of_action AS (
    SELECT
        t.id AS technique_id,
        t.stix_id AS technique_stix_id,
        c.id AS course_of_action_id,
        c.stix_id AS course_of_action_stix_id
    FROM _relationships r
    JOIN courses_of_action c ON r.source_ref = c.stix_id
    JOIN techniques t ON r.target_ref = t.stix_id
    WHERE r.relationship_type = 'mitigates'
);

-- Techniques to malware
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

-- Techniques to tools
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

-- Intrusion sets to malware
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

-- Intrusion sets to tools
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

-- Intrusion sets to techniques
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

-- Campaigns to intrusion sets
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

-- Campaigns to techniques
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

-- Campaigns to tools
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

-- Campaigns to malware
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

-- Detection strategies to techniques
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

COPY stix_ids_to_external_ids TO '/home/tyler/src/whitfieldsdad/data/layers/silver/relational/mitre-attack/stix-ids-to-external-ids.parquet';

COPY relationships TO '/home/tyler/src/whitfieldsdad/data/layers/silver/relational/mitre-attack/relationships.parquet';

COPY tactics TO '/home/tyler/src/whitfieldsdad/data/layers/silver/relational/mitre-attack/tactics.parquet';
COPY techniques TO '/home/tyler/src/whitfieldsdad/data/layers/silver/relational/mitre-attack/techniques.parquet';
COPY intrusion_sets TO '/home/tyler/src/whitfieldsdad/data/layers/silver/relational/mitre-attack/intrusion-sets.parquet';
COPY malware TO '/home/tyler/src/whitfieldsdad/data/layers/silver/relational/mitre-attack/malware.parquet';
COPY tools TO '/home/tyler/src/whitfieldsdad/data/layers/silver/relational/mitre-attack/tools.parquet';
COPY campaigns TO '/home/tyler/src/whitfieldsdad/data/layers/silver/relational/mitre-attack/campaigns.parquet';
COPY courses_of_action TO '/home/tyler/src/whitfieldsdad/data/layers/silver/relational/mitre-attack/courses-of-action.parquet';
COPY detection_strategies TO '/home/tyler/src/whitfieldsdad/data/layers/silver/relational/mitre-attack/detection-strategies.parquet';
COPY analytics TO '/home/tyler/src/whitfieldsdad/data/layers/silver/relational/mitre-attack/analytics.parquet';
COPY data_sources TO '/home/tyler/src/whitfieldsdad/data/layers/silver/relational/mitre-attack/data-sources.parquet';
COPY data_components TO '/home/tyler/src/whitfieldsdad/data/layers/silver/relational/mitre-attack/data-components.parquet';
COPY log_sources TO '/home/tyler/src/whitfieldsdad/data/layers/silver/relational/mitre-attack/log-sources.parquet';

COPY tactics_to_techniques TO '/home/tyler/src/whitfieldsdad/data/layers/silver/relational/mitre-attack/tactics-to-techniques.parquet';

COPY techniques_to_intrusion_sets TO '/home/tyler/src/whitfieldsdad/data/layers/silver/relational/mitre-attack/techniques-to-intrusion-sets.parquet';
COPY techniques_to_courses_of_action TO '/home/tyler/src/whitfieldsdad/data/layers/silver/relational/mitre-attack/techniques-to-courses-of-action.parquet';
COPY techniques_to_malware TO '/home/tyler/src/whitfieldsdad/data/layers/silver/relational/mitre-attack/techniques-to-malware.parquet';
COPY techniques_to_tools TO '/home/tyler/src/whitfieldsdad/data/layers/silver/relational/mitre-attack/techniques-to-tools.parquet';

COPY intrusion_sets_to_malware TO '/home/tyler/src/whitfieldsdad/data/layers/silver/relational/mitre-attack/intrusion-sets-to-malware.parquet';
COPY intrusion_sets_to_tools TO '/home/tyler/src/whitfieldsdad/data/layers/silver/relational/mitre-attack/intrusion-sets-to-tools.parquet';
COPY campaigns_to_intrusion_sets TO '/home/tyler/src/whitfieldsdad/data/layers/silver/relational/mitre-attack/campaigns-to-intrusion-sets.parquet';
COPY campaigns_to_techniques TO '/home/tyler/src/whitfieldsdad/data/layers/silver/relational/mitre-attack/campaigns-to-techniques.parquet';
COPY campaigns_to_tools TO '/home/tyler/src/whitfieldsdad/data/layers/silver/relational/mitre-attack/campaigns-to-tools.parquet';
COPY campaigns_to_malware TO '/home/tyler/src/whitfieldsdad/data/layers/silver/relational/mitre-attack/campaigns-to-malware.parquet';
COPY detection_strategies_to_techniques TO '/home/tyler/src/whitfieldsdad/data/layers/silver/relational/mitre-attack/detection-strategies-to-techniques.parquet';
COPY intrusion_sets_to_techniques TO '/home/tyler/src/whitfieldsdad/data/layers/silver/relational/mitre-attack/intrusion-sets-to-techniques.parquet';

COPY campaigns_to_tools TO '/home/tyler/src/whitfieldsdad/data/layers/silver/relational/mitre-attack/campaigns-to-tools.parquet';
COPY campaigns_to_malware TO '/home/tyler/src/whitfieldsdad/data/layers/silver/relational/mitre-attack/campaigns-to-malware.parquet';
COPY campaigns_to_techniques TO '/home/tyler/src/whitfieldsdad/data/layers/silver/relational/mitre-attack/campaigns-to-techniques.parquet';

COPY detection_strategies_to_techniques TO '/home/tyler/src/whitfieldsdad/data/layers/silver/relational/mitre-attack/detection-strategies-to-techniques.parquet';
COPY detection_strategies_to_analytics TO '/home/tyler/src/whitfieldsdad/data/layers/silver/relational/mitre-attack/detection-strategies-to-analytics.parquet';