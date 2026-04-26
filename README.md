# Pipery Docker CI

CI pipeline for Docker: lint (hadolint), SAST, SCA, build, test, versioning, push image, reintegration

## Status

- Owner: `pipery-dev`
- Repository: `pipery-docker-ci`
- Marketplace category: `continuous-integration`
- Current version: `0.1.0`

## Usage

```yaml
name: Example
on: [push]

jobs:
  run-action:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: pipery-dev/pipery-docker-ci@v0
        with:
          project_path: .
```

## Inputs

### Core

| Name | Default | Description |
|---|---|---|
| `project_path` | `.` | Path to the project source tree. |
| `config_file` | `` | Path to a config file for the action. |
| `log_file` | `pipery.jsonl` | Path to the JSONL log file. |

### Image configuration

| Name | Default | Description |
|---|---|---|
| `dockerfile` | `Dockerfile` | Dockerfile name relative to `project_path`. |
| `image_name` | `` | Name of the Docker image to build. |
| `image_tag` | `latest` | Tag for the Docker image. |
| `build_args` | `` | Comma-separated list of build args in `VAR=val` format. |
| `platforms` | `linux/amd64` | Platforms to build for. |

### Registry / publish credentials

| Name | Default | Description |
|---|---|---|
| `registry` | `ghcr.io` | Container registry host. |
| `registry_username` | `` | Username for registry login. |
| `registry_password` | `` | Password or token for registry login. |
| `github_token` | `` | GitHub token for reintegration. |

### Pipeline controls (skip flags)

| Name | Default | Description |
|---|---|---|
| `skip_sast` | `false` | Skip SAST scan. |
| `skip_sca` | `false` | Skip SCA scan. |
| `skip_lint` | `false` | Skip the hadolint step. |
| `skip_build` | `false` | Skip the Docker build step. |
| `skip_test` | `false` | Skip the container smoke test step. |
| `skip_versioning` | `false` | Skip the versioning step. |
| `skip_packaging` | `false` | Skip the packaging (image tagging) step. |
| `skip_release` | `false` | Skip the release (registry push) step. |
| `skip_reintegration` | `false` | Skip the reintegration step. |

### Versioning & release

| Name | Default | Description |
|---|---|---|
| `version_bump` | `patch` | Version bump type: `patch`, `minor`, or `major`. |

### Testing

| Name | Default | Description |
|---|---|---|
| `tests_path` | `` | Command or script to run inside the container for testing. Defaults to a smoke test. |

## Outputs

No outputs.

## Steps

| Step | Skip flag | What it does |
|---|---|---|
| Lint | `skip_lint` | Dockerfile static analysis via hadolint |
| SAST | `skip_sast` | Static analysis via pipery-steps |
| SCA | `skip_sca` | Dependency vulnerability scan |
| Build | `skip_build` | Build Docker image (multi-platform via buildx) |
| Test | `skip_test` | Run test command inside the container (`tests_path`) |
| Versioning | `skip_versioning` | Bump version, write to `GITHUB_OUTPUT` |
| Packaging | `skip_packaging` | Tag image with version aliases |
| Release | `skip_release` | Push image to registry (includes `sha-<shortsha>` tag) |
| Reintegration | `skip_reintegration` | Merge release branch back to default |

## Development

This repository is managed with `pipery-tooling`.

```bash
pipery-actions test --repo .
pipery-actions release --repo . --dry-run
```
