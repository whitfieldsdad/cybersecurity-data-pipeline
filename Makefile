default: clean init

init:
	find . -type f -name "*.sh" -exec chmod +x {} \;

clean:
	find . -type f -name "._*" -delete

data:
	poetry run python3 -m pipeline.flows.git run
	poetry run python3 -m pipeline.flows.cisa_kev run
	poetry run python3 -m pipeline.flows.metasploit_framework run
	poetry run python3 -m pipeline.flows.mitre_cve run
	poetry run python3 -m pipeline.flows.cvss_vectors run
	poetry run python3 -m pipeline.flows.mitre_attack run
	poetry run python3 -m pipeline.flows.mitre_capec run
	poetry run python3 -m pipeline.flows.epss run
	poetry run python3 -m pipeline.flows.vulnerability_database run

.PHONY: data init clean
