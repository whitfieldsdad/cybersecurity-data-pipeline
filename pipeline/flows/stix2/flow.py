import os

from metaflow import step
from pipeline.flows.base.flow import BaseFlow
from hodgepodge import stix
from pipeline.constants import BRONZE_GIT_DIR, SILVER_STIX2_DIR


STIX2_BUNDLES = {
    'mitre-attack-enterprise': os.path.join(BRONZE_GIT_DIR, 'mitre-attack/attack-stix-data/enterprise-attack/enterprise-attack.json'),
    'mitre-attack-mobile': os.path.join(BRONZE_GIT_DIR, 'mitre-attack/attack-stix-data/mobile-attack/mobile-attack.json'),
    'mitre-attack-ics': os.path.join(BRONZE_GIT_DIR, 'mitre-attack/attack-stix-data/ics-attack/ics-attack.json'),
    'mitre-capec': os.path.join(BRONZE_GIT_DIR, 'mitre/cti/capec/2.1/stix-capec.json'),
}


class Flow(BaseFlow):
    @step
    def start(self):
        self.next(self.expand_stix2_bundle)

    @step
    def expand_stix2_bundle(self):
        for name, input_file in STIX2_BUNDLES.items():
            output_dir = os.path.join(SILVER_STIX2_DIR, name)
            stix.expand_bundle_file(input_file, output_dir)
        self.next(self.end)

    @step
    def end(self):
        pass


if __name__ == "__main__":
    Flow()
