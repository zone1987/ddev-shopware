[![add-on registry](https://img.shields.io/badge/DDEV-Add--on_Registry-blue)](https://addons.ddev.com)
[![tests](https://github.com/zone1987/ddev-shopware/actions/workflows/tests.yml/badge.svg?branch=main)](https://github.com/zone1987/ddev-shopware/actions/workflows/tests.yml?query=branch%3Amain)
[![last commit](https://img.shields.io/github/last-commit/zone1987/ddev-shopware)](https://github.com/zone1987/ddev-shopware/commits)
[![release](https://img.shields.io/github/v/release/zone1987/ddev-shopware)](https://github.com/zone1987/ddev-shopware/releases/latest)

# DDEV Shopware

## Overview

This add-on integrates Shopware into your [DDEV](https://ddev.com/) project.

## Installation

```bash
ddev add-on get zone1987/ddev-shopware
ddev restart
```

After installation, make sure to commit the `.ddev` directory to version control.

## Usage

| Command | Description |
| ------- | ----------- |
| `ddev describe` | View service status and used ports for Shopware |
| `ddev logs -s shopware` | Check Shopware logs |

## Advanced Customization

To change the Docker image:

```bash
ddev dotenv set .ddev/.env.shopware --shopware-docker-image="ddev/ddev-utilities:latest"
ddev add-on get zone1987/ddev-shopware
ddev restart
```

Make sure to commit the `.ddev/.env.shopware` file to version control.

All customization options (use with caution):

| Variable | Flag | Default |
| -------- | ---- | ------- |
| `SHOPWARE_DOCKER_IMAGE` | `--shopware-docker-image` | `ddev/ddev-utilities:latest` |

## Credits

**Contributed and maintained by [@zone1987](https://github.com/zone1987)**
