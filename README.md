# Data pipeline

## Datasets

### Inputs

#### Files

| Name | URL |
|------|-----|
| CISA KEV | https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json |

#### Git repositories

| Name | Repository | URL |
|------|-----|----|
| Atomic Red Team | redcanaryco/atomic-red-team | https://github.com/redcanaryco/atomic-red-team.git |
| MITRE CVE | CVEProject/cvelistV5 | https://github.com/CVEProject/cvelistV5.git |
| MITRE CTI | mitre/cti | https://github.com/mitre/cti.git |
| MITRE ATT&CK | mitre-attack/attack-stix-data | https://github.com/mitre-attack/attack-stix-data.git |
| EPSS | empiricalsec/epss_scores | https://github.com/empiricalsec/epss_scores.git |
| Metasploit Framework | rapid7/metasploit-framework | https://github.com/rapid7/metasploit-framework.git |

## Usage

Flows are currently manually run one-by-one

```bash
poetry run python3 -m pipeline.flows.git run
```
