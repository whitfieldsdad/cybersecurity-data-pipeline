import os
from pathlib import Path
import subprocess


def get_project_root() -> str:
    for parent in Path(__file__).resolve().parents:
        if (parent / '.git').exists() or (parent / 'pyproject.toml').exists():
            return str(parent)
    return str(Path(__file__).resolve().parent)


def git_clone_or_pull(url: str, output_dir: str) -> bool:
    if os.path.exists(output_dir):
        print(f'Pulling {url} to {output_dir}')
        cmd = ["git", "-C", output_dir, "pull"]
    else:
        print(f'Cloning {url} to {output_dir}')
        cmd = ["git", "clone", url, output_dir, "--depth=1"]

    try:
        result = subprocess.run(
            cmd,
            capture_output=True,
            text=True,
            check=True,
        )
    except subprocess.CalledProcessError as exc:
        print(f"Git failed with return code {exc.returncode}")
        print(f"Command: {exc.cmd!r}")
        print(f"stdout:\n{exc.stdout}")
        print(f"stderr:\n{exc.stderr}")
        raise
    else:
        return result.returncode == 0


def get_real_path(path: str) -> str:
    for f in [
        os.path.expanduser,
        os.path.expandvars,
        os.path.realpath,
    ]:
        path = f(path)
    return path
