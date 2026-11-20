SET preserve_insertion_order = false;

CREATE OR REPLACE TABLE _relationships AS (
    SELECT * FROM '/home/tyler/src/whitfieldsdad/data/layers/silver/relational/mitre-attack/relationships.parquet'
);

CREATE OR REPLACE TABLE _tactics AS (
    SELECT * FROM '/home/tyler/src/whitfieldsdad/data/layers/silver/relational/mitre-attack/tactics.parquet'
);

CREATE OR REPLACE TABLE _techniques AS (
    SELECT * FROM '/home/tyler/src/whitfieldsdad/data/layers/silver/relational/mitre-attack/techniques.parquet'
);
 
CREATE OR REPLACE TABLE _intrusion_sets AS (
    SELECT * FROM '/home/tyler/src/whitfieldsdad/data/layers/silver/relational/mitre-attack/intrusion-sets.parquet'
);

CREATE OR REPLACE TABLE _campaigns AS (
    SELECT * FROM '/home/tyler/src/whitfieldsdad/data/layers/silver/relational/mitre-attack/campaigns.parquet'
);

CREATE OR REPLACE TABLE _courses_of_action AS (
    SELECT * FROM '/home/tyler/src/whitfieldsdad/data/layers/silver/relational/mitre-attack/courses-of-action.parquet'
);

CREATE OR REPLACE TABLE _malware AS (
    SELECT * FROM '/home/tyler/src/whitfieldsdad/data/layers/silver/relational/mitre-attack/malware.parquet'
);

CREATE OR REPLACE TABLE _tools AS (
    SELECT * FROM '/home/tyler/src/whitfieldsdad/data/layers/silver/relational/mitre-attack/tools.parquet'
);

CREATE OR REPLACE TABLE _analytics AS (
    SELECT * FROM '/home/tyler/src/whitfieldsdad/data/layers/silver/relational/mitre-attack/analytics.parquet'
);

CREATE OR REPLACE TABLE _analytics_to_log_sources AS (
    SELECT * FROM '/home/tyler/src/whitfieldsdad/data/layers/silver/relational/mitre-attack/analytics-to-log-sources.parquet'
);

CREATE OR REPLACE TABLE _data_components AS (
    SELECT * FROM '/home/tyler/src/whitfieldsdad/data/layers/silver/relational/mitre-attack/data-components.parquet'
);

CREATE OR REPLACE TABLE _log_sources AS (
    SELECT * FROM '/home/tyler/src/whitfieldsdad/data/layers/silver/relational/mitre-attack/log-sources.parquet'
);

CREATE OR REPLACE TABLE _detection_strategies AS (
    SELECT * FROM '/home/tyler/src/whitfieldsdad/data/layers/silver/relational/mitre-attack/detection-strategies.parquet'
);

CREATE OR REPLACE TABLE _tactics_to_techniques AS (
    SELECT * FROM '/home/tyler/src/whitfieldsdad/data/layers/silver/relational/mitre-attack/tactics-to-techniques.parquet'
);

CREATE OR REPLACE TABLE _techniques_to_malware AS (
    SELECT * FROM '/home/tyler/src/whitfieldsdad/data/layers/silver/relational/mitre-attack/techniques-to-malware.parquet'
);

CREATE OR REPLACE TABLE _techniques_to_tools AS (
    SELECT * FROM '/home/tyler/src/whitfieldsdad/data/layers/silver/relational/mitre-attack/techniques-to-tools.parquet'
);

CREATE OR REPLACE TABLE _techniques_to_intrusion_sets AS (
    SELECT * FROM '/home/tyler/src/whitfieldsdad/data/layers/silver/relational/mitre-attack/techniques-to-intrusion-sets.parquet'
);

CREATE OR REPLACE TABLE _techniques_to_courses_of_action AS (
    SELECT * FROM '/home/tyler/src/whitfieldsdad/data/layers/silver/relational/mitre-attack/techniques-to-courses-of-action.parquet'
);

CREATE OR REPLACE TABLE _intrusion_sets_to_techniques AS (
    SELECT * FROM '/home/tyler/src/whitfieldsdad/data/layers/silver/relational/mitre-attack/intrusion-sets-to-techniques.parquet'
);

CREATE OR REPLACE TABLE _campaigns_to_intrusion_sets AS (
    SELECT * FROM '/home/tyler/src/whitfieldsdad/data/layers/silver/relational/mitre-attack/campaigns-to-intrusion-sets.parquet'
);

CREATE OR REPLACE TABLE _campaigns_to_malware AS (
    SELECT * FROM '/home/tyler/src/whitfieldsdad/data/layers/silver/relational/mitre-attack/campaigns-to-malware.parquet'
);

CREATE OR REPLACE TABLE _campaigns_to_tools AS (
    SELECT * FROM '/home/tyler/src/whitfieldsdad/data/layers/silver/relational/mitre-attack/campaigns-to-tools.parquet'
);

CREATE OR REPLACE TABLE _campaigns_to_techniques AS (
    SELECT * FROM '/home/tyler/src/whitfieldsdad/data/layers/silver/relational/mitre-attack/campaigns-to-techniques.parquet'
);

CREATE OR REPLACE TABLE _detection_strategies_to_analytics AS (
    SELECT * FROM '/home/tyler/src/whitfieldsdad/data/layers/silver/relational/mitre-attack/detection-strategies-to-analytics.parquet'
);

CREATE OR REPLACE TABLE _detection_strategies_to_techniques AS (
    SELECT * FROM '/home/tyler/src/whitfieldsdad/data/layers/silver/relational/mitre-attack/detection-strategies-to-techniques.parquet'
);

CREATE OR REPLACE TABLE _intrusion_sets_to_malware AS (
    SELECT * FROM '/home/tyler/src/whitfieldsdad/data/layers/silver/relational/mitre-attack/intrusion-sets-to-malware.parquet'
);

CREATE OR REPLACE TABLE _intrusion_sets_to_tools AS (
    SELECT * FROM '/home/tyler/src/whitfieldsdad/data/layers/silver/relational/mitre-attack/intrusion-sets-to-tools.parquet'
);

CREATE OR REPLACE TABLE _intrusion_sets_to_techniques AS (
    SELECT * FROM '/home/tyler/src/whitfieldsdad/data/layers/silver/relational/mitre-attack/intrusion-sets-to-techniques.parquet'
);

-- Tactics
-- * TODO: add total techniques
CREATE OR REPLACE TABLE tactics AS (
    SELECT 
        id, 
        "name",
        --"description"
    FROM _tactics
    ORDER BY id
);

-- Techniques
-- * TODO: add total campaigns
-- * TODO: add total intrusion sets
-- * TODO: add total malware
-- * TODO: add total tools
-- * TODO: add total courses of action
CREATE OR REPLACE TABLE techniques AS (
    SELECT 
        id, 
        "name",
        --"description",
        "platforms"
    FROM _techniques
    ORDER BY id
);

-- Intrusion sets
-- * TODO: add total campaigns
-- * TODO: add total techniques
-- * TODO: add total malware
-- * TODO: add total tools
CREATE OR REPLACE TABLE intrusion_sets AS (
    SELECT 
        id, 
        "name",
        "aliases"
    FROM _intrusion_sets
    ORDER BY id
);

-- Campaigns
-- * TODO: add total intrusion sets
-- * TODO: add total techniques
-- * TODO: add total malware
-- * TODO: add total tools
CREATE OR REPLACE TABLE campaigns AS (
    SELECT 
        id, 
        "name",
        --"description",
        first_seen AS first_seen,
        last_seen AS last_seen,
        EXTRACT(YEAR FROM age(last_seen, first_seen)) AS total_years,
        EXTRACT(MONTH FROM age(last_seen, first_seen)) AS total_months,
        EXTRACT(DAY FROM age(last_seen, first_seen)) AS total_days
    FROM _campaigns
    ORDER BY id
);

-- Courses of action
-- * TODO: add total techniques
CREATE OR REPLACE TABLE courses_of_action AS (
    SELECT 
        id, 
        "name",
        --"description"
    FROM _courses_of_action
    ORDER BY id
);

-- Malware
-- * TODO: add total campaigns
-- * TODO: add total intrusion sets
-- * TODO: add total techniques
CREATE OR REPLACE TABLE malware AS (
    SELECT 
        id, 
        "name",
        "aliases",
        --"description",
        "platforms",
        "is_family"
    FROM _malware
    ORDER BY id
);

-- Tools
-- * TODO: add total campaigns
-- * TODO: add total intrusion sets
-- * TODO: add total techniques
CREATE OR REPLACE TABLE tools AS (
    SELECT 
        id, 
        "name",
        "aliases",
        --"description",
        "platforms"
    FROM _tools
    ORDER BY id
);

-- Detection strategies
CREATE OR REPLACE TABLE detection_strategies AS (
    SELECT 
        id, 
        "name"
    FROM _detection_strategies
    ORDER BY id
);

-- Analytics
CREATE OR REPLACE TABLE analytics AS (
    SELECT 
        id, 
        "name",
        --"description",
        "platforms"
    FROM _analytics
    ORDER BY id
);

-- Data components
CREATE OR REPLACE TABLE data_components AS (
    SELECT 
        id, 
        "name"
    FROM _data_components
    ORDER BY id
);

-- Tactics, techniques, and procedures (TTPs)
CREATE OR REPLACE TABLE ttps AS (
    SELECT
        tactic.id AS tactic_id,
        tactic.name AS tactic_name,
        technique.id AS technique_id,
        technique.name AS technique_name
    FROM _tactics_to_techniques t2t
    JOIN _tactics tactic ON t2t.tactic_id = tactic.id
    JOIN _techniques technique ON t2t.technique_id = technique.id
    ORDER BY technique_id, tactic_id
);

-- Campaigns to intrusion sets
CREATE OR REPLACE TABLE campaigns_to_intrusion_sets AS (
    SELECT
        i.id AS intrusion_set_id,
        i.name AS intrusion_set_name,
        i.aliases AS intrusion_set_aliases,
        c.id AS campaign_id,
        c.name AS campaign_name
    FROM _campaigns_to_intrusion_sets c2i
    JOIN _campaigns c ON c.id = c2i.campaign_id
    JOIN _intrusion_sets i ON i.id = c2i.intrusion_set_id
    ORDER BY campaign_id, intrusion_set_id
);

-- Campaigns to TTPs
CREATE OR REPLACE TABLE campaigns_to_ttps AS (
    SELECT
        c.id AS campaign_id,
        c.name AS campaign_name,
        ttp.tactic_id,
        ttp.tactic_name,
        ttp.technique_id,
        ttp.technique_name
    FROM _campaigns_to_techniques c2t
    JOIN ttps ttp ON c2t.technique_id = ttp.technique_id
    JOIN _campaigns c ON c2t.campaign_id = c.id
    ORDER BY campaign_id, technique_id, tactic_id
);

-- Campaigns to malware
CREATE OR REPLACE TABLE campaigns_to_malware AS (
    SELECT
        c.id AS campaign_id,
        c.name AS campaign_name,
        m.id AS malware_id,
        m.name AS malware_name,
        m.aliases AS malware_aliases,
        m.is_family AS malware_is_family,
        m.platforms AS malware_platforms
    FROM _campaigns_to_malware c2m
    JOIN _campaigns c ON c2m.campaign_id = c.id
    JOIN _malware m ON c2m.malware_id = m.id
    ORDER BY campaign_id, malware_id
);

-- Campaigns to tools
CREATE OR REPLACE TABLE campaigns_to_tools AS (
    SELECT
        c.id AS campaign_id,
        c.name AS campaign_name,
        t.id AS tool_id,
        t.name AS tool_name,
        t.aliases AS tool_aliases,
        t.platforms AS tool_platforms
    FROM _campaigns_to_tools c2t
    JOIN _campaigns c ON c2t.campaign_id = c.id
    JOIN _tools t ON c2t.tool_id = t.id
    ORDER BY campaign_id, tool_id
);

-- Intrusion sets to TTPs
CREATE OR REPLACE TABLE intrusion_sets_to_ttps AS (
    SELECT
        intrusion_set.id AS intrusion_set_id,
        intrusion_set.name AS intrusion_set_name,
        intrusion_set.aliases AS intrusion_set_aliases,
        ttp.tactic_id,
        ttp.tactic_name,
        ttp.technique_id,
        ttp.technique_name
    FROM _intrusion_sets_to_techniques i2t
    JOIN ttps ttp ON i2t.technique_id = ttp.technique_id
    JOIN _intrusion_sets intrusion_set ON i2t.intrusion_set_id = intrusion_set.id
    ORDER BY intrusion_set_id, technique_id, tactic_id
);

-- Intrusion sets to campaigns
CREATE OR REPLACE TABLE intrusion_sets_to_campaigns AS (
    SELECT
        intrusion_set_id,
        intrusion_set_name,
        intrusion_set_aliases,
        campaign_id,
        campaign_name
    FROM campaigns_to_intrusion_sets
    ORDER BY intrusion_set_id, campaign_id
);

-- Intrusion sets to malware
CREATE OR REPLACE TABLE intrusion_sets_to_malware AS (
    SELECT
        i.id AS intrusion_set_id,
        i.name AS intrusion_set_name,
        i.aliases AS intrusion_set_aliases,
        m.id AS malware_id,
        m.name AS malware_name,
        m.aliases AS malware_aliases,
        m.is_family AS malware_is_family,
        m.platforms AS malware_platforms
    FROM _intrusion_sets_to_malware i2m
    JOIN _intrusion_sets i ON i2m.intrusion_set_id = i.id
    JOIN _malware m ON i2m.malware_id = m.id
    ORDER BY intrusion_set_id, malware_id
);

-- Intrusion sets to tools
CREATE OR REPLACE TABLE intrusion_sets_to_tools AS (
    SELECT
        i.id AS intrusion_set_id,
        i.name AS intrusion_set_name,
        i.aliases AS intrusion_set_aliases,
        t.id AS tool_id,
        t.name AS tool_name,
        t.aliases AS tool_aliases,
        t.platforms AS tool_platforms
    FROM _intrusion_sets_to_tools i2t
    JOIN _intrusion_sets i ON i2t.intrusion_set_id = i.id
    JOIN _tools t ON i2t.tool_id = t.id
    ORDER BY intrusion_set_id, tool_id
);

-- Malware to TTPs
CREATE OR REPLACE TABLE malware_to_ttps AS (
    SELECT
        m.id AS malware_id,
        m.name AS malware_name,
        m.aliases AS malware_aliases,
        m.is_family AS malware_is_family,
        m.platforms AS malware_platforms,
        ttp.tactic_id,
        ttp.tactic_name,
        ttp.technique_id,
        ttp.technique_name
    FROM _techniques_to_malware t2m
    JOIN ttps ttp ON t2m.technique_id = ttp.technique_id
    JOIN _malware m ON t2m.malware_id = m.id
);

-- Tools to TTPs
CREATE OR REPLACE TABLE tools_to_ttps AS (
    SELECT
        t.id AS tool_id,
        t.name AS tool_name,
        t.aliases AS tool_aliases,
        t.platforms AS tool_platforms,
        ttp.tactic_id,
        ttp.tactic_name,
        ttp.technique_id,
        ttp.technique_name
    FROM _techniques_to_tools t2t
    JOIN ttps ttp ON t2t.technique_id = ttp.technique_id
    JOIN _tools t ON t2t.tool_id = t.id
);

-- Courses of action to TTPs
CREATE OR REPLACE TABLE courses_of_action_to_ttps AS (
    SELECT
        coa.id AS course_of_action_id,
        coa.name AS course_of_action_name,
        ttp.tactic_id,
        ttp.tactic_name,
        ttp.technique_id,
        ttp.technique_name
    FROM _techniques_to_courses_of_action t2c
    JOIN ttps ttp ON t2c.technique_id = ttp.technique_id
    JOIN _courses_of_action coa ON t2c.course_of_action_id = coa.id
    ORDER BY course_of_action_id, tactic_id, technique_id
);

-- Detection strategies to analytics
CREATE OR REPLACE TABLE ttps_to_detection_strategies_to_log_sources AS (
    SELECT
        tactic.id AS tactic_id,
        tactic.name AS tactic_name,
        technique.id AS technique_id,
        technique.name AS technique_name,
        ds.id AS detection_strategy_id,
        ds.name AS detection_strategy_name,
        a.id AS analytic_id,
        a.name AS analytic_name,
        dc.id AS data_component_id,
        dc.name AS data_component_name,
        ls.name AS log_source_name,
        ls.channel AS log_source_channel
    FROM _detection_strategies_to_analytics d2a
    JOIN _detection_strategies_to_techniques d2t ON d2t.detection_strategy_id = d2a.detection_strategy_id
    JOIN _tactics_to_techniques t2t ON d2t.technique_id = t2t.technique_id
    JOIN _tactics tactic ON t2t.tactic_id = tactic.id
    JOIN _techniques technique ON d2t.technique_id = technique.id
    JOIN _detection_strategies ds ON d2a.detection_strategy_id = ds.id
    JOIN _analytics a ON d2a.analytic_stix_id = a.stix_id
    JOIN _analytics_to_log_sources a2ls ON a2ls.analytic_id = a.id
    JOIN _log_sources ls ON a2ls.name = ls.name
    JOIN _data_components dc ON ls.data_component_stix_id = dc.stix_id
    ORDER BY tactic_id, technique_id, detection_strategy_id, analytic_id, data_component_id, log_source_name
);

-- Detection strategies to log sources
CREATE OR REPLACE TABLE detection_strategies_to_log_sources AS (
    SELECT
        detection_strategy_id,
        detection_strategy_name,
        analytic_id,
        analytic_name,
        data_component_id,
        data_component_name,
        log_source_name,
        log_source_channel
    FROM ttps_to_detection_strategies_to_log_sources
    ORDER BY detection_strategy_id, analytic_id, data_component_id, log_source_name
);

-- Data components to TTPs
CREATE OR REPLACE TABLE data_components_to_ttps AS (
    SELECT
        data_component_id,
        data_component_name,
        tactic_id,
        tactic_name,
        technique_id,
        technique_name
    FROM ttps_to_detection_strategies_to_log_sources
    ORDER BY data_component_id, tactic_id, technique_id
);

COPY analytics TO '/home/tyler/src/whitfieldsdad/data/layers/gold/analyst/mitre-attack/analytics.parquet';
COPY campaigns TO '/home/tyler/src/whitfieldsdad/data/layers/gold/analyst/mitre-attack/campaigns.parquet';
COPY courses_of_action TO '/home/tyler/src/whitfieldsdad/data/layers/gold/analyst/mitre-attack/courses-of-action.parquet';
COPY data_components TO '/home/tyler/src/whitfieldsdad/data/layers/gold/analyst/mitre-attack/data-components.parquet';
COPY detection_strategies TO '/home/tyler/src/whitfieldsdad/data/layers/gold/analyst/mitre-attack/detection-strategies.parquet';
COPY intrusion_sets TO '/home/tyler/src/whitfieldsdad/data/layers/gold/analyst/mitre-attack/intrusion-sets.parquet';
COPY malware TO '/home/tyler/src/whitfieldsdad/data/layers/gold/analyst/mitre-attack/malware.parquet';
COPY tactics TO '/home/tyler/src/whitfieldsdad/data/layers/gold/analyst/mitre-attack/tactics.parquet';
COPY techniques TO '/home/tyler/src/whitfieldsdad/data/layers/gold/analyst/mitre-attack/techniques.parquet';
COPY tools TO '/home/tyler/src/whitfieldsdad/data/layers/gold/analyst/mitre-attack/tools.parquet';

COPY ttps TO '/home/tyler/src/whitfieldsdad/data/layers/gold/analyst/mitre-attack/ttps.parquet';

COPY campaigns_to_intrusion_sets TO '/home/tyler/src/whitfieldsdad/data/layers/gold/analyst/mitre-attack/campaigns-to-intrusion-sets.parquet';
COPY campaigns_to_ttps TO '/home/tyler/src/whitfieldsdad/data/layers/gold/analyst/mitre-attack/campaigns-to-ttps.parquet';
COPY campaigns_to_malware TO '/home/tyler/src/whitfieldsdad/data/layers/gold/analyst/mitre-attack/campaigns-to-malware.parquet';
COPY campaigns_to_tools TO '/home/tyler/src/whitfieldsdad/data/layers/gold/analyst/mitre-attack/campaigns-to-tools.parquet';

COPY intrusion_sets_to_ttps TO '/home/tyler/src/whitfieldsdad/data/layers/gold/analyst/mitre-attack/intrusion-sets-to-ttps.parquet';
COPY intrusion_sets_to_campaigns TO '/home/tyler/src/whitfieldsdad/data/layers/gold/analyst/mitre-attack/intrusion-sets-to-campaigns.parquet';
COPY intrusion_sets_to_malware TO '/home/tyler/src/whitfieldsdad/data/layers/gold/analyst/mitre-attack/intrusion-sets-to-malware.parquet';
COPY intrusion_sets_to_tools TO '/home/tyler/src/whitfieldsdad/data/layers/gold/analyst/mitre-attack/intrusion-sets-to-tools.parquet';

COPY malware_to_ttps TO '/home/tyler/src/whitfieldsdad/data/layers/gold/analyst/mitre-attack/malware-to-ttps.parquet';

COPY tools_to_ttps TO '/home/tyler/src/whitfieldsdad/data/layers/gold/analyst/mitre-attack/tools-to-ttps.parquet';

COPY courses_of_action_to_ttps TO '/home/tyler/src/whitfieldsdad/data/layers/gold/analyst/mitre-attack/courses-of-action-to-ttps.parquet';

COPY ttps_to_detection_strategies_to_log_sources TO '/home/tyler/src/whitfieldsdad/data/layers/gold/analyst/mitre-attack/ttps-to-detection-strategies-to-log-sources.parquet';
COPY detection_strategies_to_log_sources TO '/home/tyler/src/whitfieldsdad/data/layers/gold/analyst/mitre-attack/detection-strategies-to-log-sources.parquet';
COPY data_components_to_ttps TO '/home/tyler/src/whitfieldsdad/data/layers/gold/analyst/mitre-attack/data-components-to-ttps.parquet';