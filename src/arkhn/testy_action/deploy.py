import logging
from pathlib import Path

import ansible_runner

logger = logging.getLogger(__file__)


def make_host_vars(host: str, cloud_key_file: Path, **kwargs) -> dict:
    return {
        "ansible_host": host,
        "ansible_user": "root",
        "ansible_ssh_private_key_file": str(cloud_key_file),
        "extended_stack": False,
        "public_host": "localhost",
        "api_domain": "reverse-proxy",
        "stage": "aphp",
        "use_ssl": False,
        "public_port": 8080,
        **kwargs,
    }


def deploy_stack(
    runner_dir: Path,
    playbook_dir: Path,
    host_vars: dict,
):
    inventory = {"all": {"hosts": {"test": host_vars}}}

    logger.debug(inventory)

    ansible_runner.interface.run(
        playbook="play.yml",
        private_data_dir=str(runner_dir),
        project_dir=str(playbook_dir),
        inventory=inventory,
        extravars={"host_is_bounded": True},
    )
