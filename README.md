# Data pipeline

## Datasets

| Name | Pipeline stage | Notes |
| :--- | :--- | :--- |
| MITRE ATT&CK | `stix2` | |
| MITRE CAPEC | `stix2` | |
| MITRE CWE | `stix2` | |
| MITRE CVE | `mitre_cve` | MITRE CVE references MITRE CWE. |
| CVSS | `cvss_vectors` | CVSS vectors are extracted from MITRE CVE and expanded. |
| CISA KEV | `cisa_kev` | CISA KEV references MITRE CVE and CWE. |
| EPSS | `epss` | EPSS references MITRE CVE. |
| Metasploit Framework | `metasploit_framework` | Generated from the [Metasploit Framework module database](https://raw.githubusercontent.com/rapid7/metasploit-framework/refs/heads/master/db/modules_metadata_base.json). The Metasploit Framework references MITRE ATT&CK and CVE. |
| Vulnerability Database | `vulnerability_database` | References MITRE CVE and CWE. |

## Usage

To run the data pipeline:

```sh
poetry run pipeline
```

To run a specific pipeline stage (e.g. `git`):

```sh
poetry run pipeline git
```
