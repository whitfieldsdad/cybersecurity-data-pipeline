import click
from metaflow import Runner

FLOWS = [
    "git", 
    "stix2", 
    "mitre_attack", 
    "mitre_capec", 
    "mitre_cwe", 
    "metasploit_framework", 
    "cisa_kev", 
    "mitre_cve",
    "cvss_vectors", 
    "epss",
    "vulnerability_database"
]


@click.command()
@click.argument("stage", required=False)
def main(stage):
    stages = [stage] if stage else FLOWS
    for name in stages:
        with Runner(f"pipeline/flows/{name}/flow.py").run() as running:
            print(f"{name}: {running.status}")
            if running.status != "successful":
                raise SystemExit(f"{name} failed")


if __name__ == "__main__":
    main()
