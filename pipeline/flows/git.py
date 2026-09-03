from metaflow import FlowSpec, step
from pipeline import files
import os

from pipeline.constants import DATA_DIR


GIT_REPOSITORIES = {
    "redcanaryco/atomic-red-team": "https://github.com/redcanaryco/atomic-red-team.git",
    "CVEProject/cvelistV5": "https://github.com/CVEProject/cvelistV5.git",
    "mitre/cti": "https://github.com/mitre/cti.git",
    "mitre-attack/attack-stix-data": "https://github.com/mitre-attack/attack-stix-data.git",
    "empiricalsec/epss_scores": "https://github.com/empiricalsec/epss_scores.git",
    "rapid7/metasploit-framework": "https://github.com/rapid7/metasploit-framework.git"
}

class Flow(FlowSpec):
    @step
    def start(self):
        self.output_dir = os.path.join(DATA_DIR, 'layers/bronze/git/')
        self.git_repositories = list(GIT_REPOSITORIES.items())
        self.next(self.sync_git_repository, foreach="git_repositories")

    @step
    def sync_git_repository(self):
        name, url = self.input
        output_dir = os.path.join(self.output_dir, name)
        print(f"Syncing {name} from {url} to {output_dir}")

        os.makedirs(os.path.dirname(output_dir), exist_ok=True)
        files.git_clone_or_pull(url, output_dir)
        self.next(self.join)

    @step
    def join(self, _):
        self.next(self.end)

    @step
    def end(self):
        pass


if __name__ == "__main__":
    Flow()
