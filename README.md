# <img src="https://raw.githubusercontent.com/pipery-dev/pipery-docker-ci/main/assets/icon.png" alt="Pipery Docker CI" width="28" align="center" /> Pipery Docker CI

Reusable GitHub Action for a complete Docker CI pipeline with structured logging via [Pipery](https://pipery.dev).

[![GitHub Marketplace](https://img.shields.io/badge/Marketplace-Pipery%20Docker%20CI-blue?logo=github)](https://github.com/marketplace/actions/pipery-docker-ci)
[![Version](https://img.shields.io/badge/version-1.0.0-blue)](CHANGELOG.md)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

## Table of Contents

- [Quick Start](#quick-start)
- [Pipeline Overview](#pipeline-overview)
- [Configuration Options](#configuration-options)
- [Usage Examples](#usage-examples)
- [GitLab CI](#gitlab-ci)
- [Bitbucket Pipelines](#bitbucket-pipelines)
- [About Pipery](#about-pipery)
- [Development](#development)

## Quick Start

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
          project_path: .
          image_name: ghcr.io/${{ github.repository }}
          image_tag: ${{ github.sha }}
          registry_password: ${{ secrets.GITHUB_TOKEN }}
          github_token: ${{ secrets.GITHUB_TOKEN }}
```

## Pipeline Overview

| Step | Tool | Skip Input | Description |
| --- | --- | --- | --- |
| Lint | hadolint | `skip_lint` | Validates Dockerfile syntax and best practices |
| SAST | Trivy | `skip_sast` | Detects Docker image vulnerabilities |
| SCA | Grype / syft | `skip_sca` | Identifies vulnerable dependencies |
| Build | docker build | `skip_build` | Builds Docker image |
| Test | Container smoke test | `skip_test` | Runs container tests |
| Version | Semantic versioning | `skip_versioning` | Bumps version and creates git tag |
| Packaging | Image tagging | `skip_packaging` | Tags image with versions |
| Release | docker push | `skip_release` | Pushes to container registry |
| Reintegrate | Git merge | `skip_reintegration` | Merges back to default branch |

## Configuration Options

| Name | Default | Description |
| --- | --- | --- |
| `project_path` | `.` | Path to the project source tree. |
| `config_file` | `` | Path to config file for the action. |
| `dockerfile` | `Dockerfile` | Dockerfile name relative to project_path. |
| `image_name` | `` | Name of the Docker image to build. |
| `image_tag` | `latest` | Tag for the Docker image. |
| `registry` | `ghcr.io` | Container registry hostname. |
| `registry_username` | `` | Username for registry login. |
| `registry_password` | `` | Password or token for registry login. |
| `build_args` | `` | Comma-separated build args in VAR=val format. |
| `platforms` | `linux/amd64` | Platforms to build for (e.g., `linux/amd64,linux/arm64`). |
| `tests_path` | `` | Command or script to run inside container for testing. |
| `version_bump` | `patch` | Version bump type: `patch`, `minor`, or `major`. |
| `github_token` | `` | GitHub token for reintegration. |
| `log_file` | `pipery.jsonl` | Path to the JSONL structured log file. |
| `skip_lint` | `false` | Skip the hadolint step. |
| `skip_sast` | `false` | Skip the SAST step. |
| `skip_sca` | `false` | Skip the SCA step. |
| `skip_build` | `false` | Skip the Docker build step. |
| `skip_test` | `false` | Skip the container smoke test step. |
| `skip_versioning` | `false` | Skip the versioning step. |
| `skip_packaging` | `false` | Skip the packaging (image tagging) step. |
| `skip_release` | `false` | Skip the release (registry push) step. |
| `skip_reintegration` | `false` | Skip the reintegration step. |

## Usage Examples

### Example 1: Basic Docker image build and push

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
          project_path: .
          image_name: ghcr.io/${{ github.repository }}
          image_tag: ${{ github.sha }}
          registry_username: ${{ secrets.REGISTRY_USERNAME }}
          registry_password: ${{ secrets.REGISTRY_PASSWORD }}
          github_token: ${{ secrets.GITHUB_TOKEN }}
```

### Example 2: Build for multiple platforms (amd64 + arm64)

```yaml
- uses: pipery-dev/pipery-docker-ci@v1
  with:
    project_path: .
    image_name: ghcr.io/${{ github.repository }}
    platforms: linux/amd64,linux/arm64
    registry_password: ${{ secrets.GITHUB_TOKEN }}
    github_token: ${{ secrets.GITHUB_TOKEN }}
```

### Example 3: Skip security scanning for speed

```yaml
- uses: pipery-dev/pipery-docker-ci@v1
  with:
    project_path: .
    image_name: myapp
    skip_sast: true
    skip_sca: true
    github_token: ${{ secrets.GITHUB_TOKEN }}
```

### Example 4: Custom Dockerfile with build arguments

```yaml
- uses: pipery-dev/pipery-docker-ci@v1
  with:
    project_path: ./docker
    dockerfile: Dockerfile.prod
    image_name: myapp
    build_args: BUILD_DATE=${{ github.event.head_commit.timestamp }},VCS_REF=${{ github.sha }}
    registry_password: ${{ secrets.REGISTRY_PASSWORD }}
```

### Example 5: Container health check test

```yaml
- uses: pipery-dev/pipery-docker-ci@v1
  with:
    project_path: .
    image_name: myapp
    tests_path: curl http://localhost:8080/health || exit 1
    github_token: ${{ secrets.GITHUB_TOKEN }}
```

### Example 6: Minor version bump for release

```yaml
- uses: pipery-dev/pipery-docker-ci@v1
  with:
    project_path: .
    image_name: ghcr.io/${{ github.repository }}
    version_bump: minor
    registry_password: ${{ secrets.GITHUB_TOKEN }}
    github_token: ${{ secrets.GITHUB_TOKEN }}
```

## GitLab CI

This repository includes a GitLab CI equivalent at `.gitlab-ci.yml`. Copy it into a GitLab project or use it as a reference implementation for running the same Pipery pipeline outside GitHub Actions.

The GitLab pipeline maps action inputs to CI/CD variables, publishes `pipery.jsonl` as an artifact, and maintains the same skip controls. Store credentials as protected GitLab CI/CD variables.

```yaml
include:
  - remote: https://raw.githubusercontent.com/pipery-dev/pipery-docker-ci/v1/.gitlab-ci.yml
```

### GitLab CI Variables

Configure these protected variables in **Settings > CI/CD > Variables**:

- `REGISTRY_PASSWORD` - Registry authentication token
- `GITHUB_TOKEN` - GitHub API access for reintegration
- `IMAGE_NAME` - Docker image name (e.g., ghcr.io/org/app)

## Bitbucket Pipelines

Bitbucket Cloud pipelines provide an alternative to GitHub Actions. The equivalent pipeline configuration is in `bitbucket-pipelines.yml`.

### Getting Started

1. Copy `bitbucket-pipelines.yml` to your Bitbucket repository root
2. Configure Protected Variables in **Repository Settings > Pipelines > Repository Variables**:
   - `REGISTRY_PASSWORD` - Container registry password or token
   - `GITHUB_TOKEN` - GitHub API access (for reintegration)
   - `IMAGE_NAME` - Docker image name (e.g., ghcr.io/org/app)
3. Commit and push to trigger the pipeline

### Pipeline Stages

The Bitbucket equivalent follows the same structure:

checkout → setup → lint (hadolint) → SAST (Trivy) → SCA (Grype) → build → test → versioning → packaging → release → reintegration → logs

### Skip Flags

Disable any stage using environment variables:

- `SKIP_LINT`, `SKIP_SAST`, `SKIP_SCA`, `SKIP_BUILD`, `SKIP_TEST`, `SKIP_VERSIONING`, `SKIP_PACKAGING`, `SKIP_RELEASE`, `SKIP_REINTEGRATION`

Example: Set `SKIP_LINT=true` to skip Dockerfile linting.

### Features

- Docker image linting (hadolint)
- Container vulnerability scanning (Trivy, Grype)
- Multi-platform builds (amd64, arm64, etc.)
- Custom build arguments support
- Container smoke testing
- Automatic versioning and tagging
- Docker registry push with auth
- JSONL-based pipeline logging
- 30-90 day artifact retention

## About Pipery

<img src="https://avatars.githubusercontent.com/u/270923927?s=32" alt="Pipery" width="22" align="center" /> [**Pipery**](https://pipery.dev) is an open-source CI/CD observability platform. Every step script runs under **psh** (Pipery Shell), which intercepts all commands and emits structured JSONL events — giving you full visibility into your pipeline without any manual instrumentation.

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
