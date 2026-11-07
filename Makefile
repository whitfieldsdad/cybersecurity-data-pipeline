default: clean init

init:
	find . -type f -name "*.sh" -exec chmod +x {} \;

clean:
	find . -type f -name "._*" -delete

docs:
	dot -Tpng docs/data-lineage.dot -o docs/data-lineage.png

data:
	poetry run python3 -m pipeline.flows.git.flow run
	poetry run python3 -m pipeline.flows.stix2.flow run
	poetry run python3 -m pipeline.flows.cisa_kev.flow run
	poetry run python3 -m pipeline.flows.metasploit_framework.flow run
	poetry run python3 -m pipeline.flows.mitre_cve.flow run
	poetry run python3 -m pipeline.flows.cvss_vectors.flow run
	poetry run python3 -m pipeline.flows.mitre_attack.flow run
	poetry run python3 -m pipeline.flows.mitre_capec.flow run
	poetry run python3 -m pipeline.flows.epss.flow run
	poetry run python3 -m pipeline.flows.vulnerability_database.flow run

.PHONY: data init clean docs