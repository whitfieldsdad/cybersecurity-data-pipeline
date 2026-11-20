# Notes

## Relationships

Relationships from STIX `relationship` objects:

![Relationships from STIX Relationship Objects (SROs)](relationships-from-sros.png)

## Relationship descriptions

Relationship descriptions are available for a subset of the relationships that exist between attack patterns, campaigns, courses of action, detection strategies, intrusion sets, malware, and tools.

![Relationships with descriptions](relationships-with-descriptions.png)

```sql
SELECT 
    source_type, 
    relationship_type, 
    target_type,
    CASE WHEN "description" IS NULL THEN false ELSE true END AS description_available,
    COUNT(*) AS total
FROM '/home/tyler/src/whitfieldsdad/data/layers/silver/relational/mitre-attack/relationships.parquet'
GROUP BY * 
ORDER BY *;
```

|        source_type         | relationship_type |  target_type   | description_available |
|----------------------------|-------------------|----------------|-----------------------|
| attack-pattern             | revoked-by        | attack-pattern | false                 |
| attack-pattern             | subtechnique-of   | attack-pattern | false                 |
| campaign                   | attributed-to     | intrusion-set  | false                 |
| campaign                   | attributed-to     | intrusion-set  | true                  |
| campaign                   | uses              | attack-pattern | true                  |
| campaign                   | uses              | malware        | true                  |
| campaign                   | uses              | tool           | true                  |
| course-of-action           | mitigates         | attack-pattern | true                  |
| intrusion-set              | revoked-by        | intrusion-set  | false                 |
| intrusion-set              | uses              | attack-pattern | true                  |
| intrusion-set              | uses              | malware        | false                 |
| intrusion-set              | uses              | malware        | true                  |
| intrusion-set              | uses              | tool           | false                 |
| intrusion-set              | uses              | tool           | true                  |
| malware                    | revoked-by        | malware        | false                 |
| malware                    | revoked-by        | tool           | false                 |
| malware                    | uses              | attack-pattern | true                  |
| tool                       | uses              | attack-pattern | true                  |
| x-mitre-detection-strategy | detects           | attack-pattern | false                 |

## Tables

Node tables:

- `tactics`
- `techniques`
- `intrusion_sets`
- `campaigns`
- `courses_of_action`
- `malware`
- `tools`
- `detection_strategies`
- `analytics`
- `data_components`

Edge tables:

- `campaigns_to_intrusion_sets`
- `campaigns_to_ttps`
- `campaigns_to_malware`
- `campaigns_to_tools`

- `intrusion_sets_to_ttps`
- `intrusion_sets_to_campaigns`
- `intrusion_sets_to_malware`
- `intrusion_sets_to_tools`

- `malware_to_ttps`

- `tools_to_ttps`

- `courses_of_action_to_ttps`

- `ttps_to_detection_strategies_to_log_sources`
- `detection_strategies_to_log_sources`
- `data_components_to_ttps`

Table focal points are as follows in order of precedence:

- Campaigns
- Intrusion sets
- Malware
- Tools
- Courses of action
- TTPs
- Detection strategies
