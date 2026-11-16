# Data pipeline

## Datasets

| Name | Notes |
| :--- | :--- |
| MITRE ATT&CK | |
| MITRE CAPEC | |
| MITRE CWE | |
| MITRE CVE | MITRE CVE references MITRE CWE. |
| CVSS | CVSS vectors are extracted from MITRE CVE and expanded. |
| CISA KEV | CISA KEV references MITRE CVE and CWE. |
| EPSS | EPSS references MITRE CVE. |
| Metasploit Framework | Generated from the [Metasploit Framework module database](https://raw.githubusercontent.com/rapid7/metasploit-framework/refs/heads/master/db/modules_metadata_base.json). The Metasploit Framework references MITRE ATT&CK and CVE. |

## Usage

Flows are currently manually run one-by-one

```bash
poetry run python3 -m pipeline.flows.git run
poetry run python3 -m pipeline.flows.cisa_kev run
poetry run python3 -m pipeline.flows.metasploit_framework run
poetry run python3 -m pipeline.flows.mitre_cve run
poetry run python3 -m pipeline.flows.cvss_vectors run
poetry run python3 -m pipeline.flows.mitre_attack run
poetry run python3 -m pipeline.flows.mitre_capec run
poetry run python3 -m pipeline.flows.epss run
poetry run python3 -m pipeline.flows.vulnerability_database run
```
