# <img src="https://raw.githubusercontent.com/feathericons/feather/master/icons/anchor.svg" width="28" align="center" /> Pipery Docker CI

Reusable GitHub Action for a complete Docker CI pipeline with structured logging via [Pipery](https://pipery.dev).

[![GitHub Marketplace](https://img.shields.io/badge/Marketplace-Pipery%20Docker%20CI-blue?logo=github)](https://github.com/marketplace/actions/pipery-docker-ci)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

## Usage

```yaml
name: CI
on: [push, pull_request]

jobs:
  ci:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: pipery-dev/pipery-docker-ci@v1
        with:
          image_name: ghcr.io/${{ github.repository }}
          registry_username: ${{ github.actor }}
          registry_password: ${{ secrets.GITHUB_TOKEN }}
          github_token: ${{ secrets.GITHUB_TOKEN }}
```

## Pipeline steps

| Step | Tool | Skip input |
|---|---|---|
| Lint | Hadolint | `skip_lint` |
| SAST | Trivy (config scan) | `skip_sast` |
| SCA | Trivy (image scan) | `skip_sca` |
| Build | `docker build` | `skip_build` |
| Test | Container smoke test | `skip_test` |
| Version | Semantic version bump | `skip_versioning` |
| Package | Image tagging | `skip_packaging` |
| Release | Registry push + SHA tag | `skip_release` |
| Reintegrate | Merge back to default branch | `skip_reintegration` |

## Inputs

| Name | Default | Description |
|---|---|---|
| `project_path` | `.` | Path to the project source tree. |
| `config_file` | `` | Path to a Pipery config file. |
| `dockerfile` | `Dockerfile` | Dockerfile name relative to `project_path`. |
| `image_name` | `` | Docker image name (e.g. `ghcr.io/org/app`). |
| `image_tag` | `latest` | Tag for the built image. |
| `registry` | `ghcr.io` | Container registry host. |
| `registry_username` | `` | Registry login username. |
| `registry_password` | `` | Registry login password or token. |
| `build_args` | `` | Comma-separated `VAR=val` build args. |
| `platforms` | `linux/amd64` | Platforms to build for. |
| `tests_path` | `` | Command or script run inside the container for testing. |
| `version_bump` | `patch` | Version bump type: `patch`, `minor`, or `major`. |
| `github_token` | `` | GitHub token for reintegration. |
| `log_file` | `pipery.jsonl` | Path to the JSONL structured log file. |
| `skip_sast` | `false` | Skip the SAST step. |
| `skip_sca` | `false` | Skip the SCA step. |
| `skip_lint` | `false` | Skip the Hadolint step. |
| `skip_build` | `false` | Skip the Docker build step. |
| `skip_test` | `false` | Skip the container smoke test. |
| `skip_versioning` | `false` | Skip the versioning step. |
| `skip_packaging` | `false` | Skip image tagging. |
| `skip_release` | `false` | Skip the registry push. |
| `skip_reintegration` | `false` | Skip the reintegration step. |

## About Pipery

<img src="https://raw.githubusercontent.com/feathericons/feather/master/icons/zap.svg" width="18" align="center" /> [**Pipery**](https://pipery.dev) is an open-source CI/CD observability platform. Every step script runs under **psh** (Pipery Shell), which intercepts all commands and emits structured JSONL events — giving you full visibility into your pipeline without any manual instrumentation.

- Browse logs in the [Pipery Dashboard](https://github.com/pipery-dev/pipery-dashboard)
- Find all Pipery actions on [GitHub Marketplace](https://github.com/marketplace?q=pipery&type=actions)
- Source code: [pipery-dev](https://github.com/pipery-dev)

## Development

```bash
# Run the action locally against test-project/
pipery-actions test --repo .

# Regenerate docs
pipery-actions docs --repo .

# Dry-run release
pipery-actions release --repo . --dry-run
```
