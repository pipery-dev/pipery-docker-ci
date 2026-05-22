# Pipery Docker CI

CI pipeline for Docker: lint (hadolint), SAST, SCA, build, test, versioning, push image, reintegration

## Status

- Owner: `pipery-dev`
- Repository: `pipery-docker-ci`
- Marketplace category: `continuous-integration`
- Current version: `1.0.2`

## Usage

```yaml
name: Example
on: [push]

jobs:
  run-action:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: pipery-dev/pipery-docker-ci@v1
        with:
          project_path: .
          config_file: 
          dockerfile: Dockerfile
          image_name: 
          image_tag: latest
          registry: ghcr.io
          registry_username: 
          registry_password: 
          skip_sast: false
          skip_sca: false
          skip_lint: false
          skip_build: false
          tests_path: 
          skip_test: false
          skip_versioning: false
          skip_packaging: false
          skip_release: false
          skip_reintegration: false
          version_bump: patch
          github_token: 
          log_file: pipery.jsonl
          build_args: 
          platforms: linux/amd64
```

## Inputs

| Name | Required | Default | Description |
| --- | --- | --- | --- |
| `project_path` | no | `.` | Path to the project source tree. |
| `config_file` | no | `` | Path to a config file for the action. |
| `dockerfile` | no | `Dockerfile` | Dockerfile name relative to project_path. |
| `image_name` | no | `` | Name of the Docker image to build. |
| `image_tag` | no | `latest` | Tag for the Docker image. |
| `registry` | no | `ghcr.io` | Container registry host. |
| `registry_username` | no | `` | Username for registry login. |
| `registry_password` | no | `` | Password or token for registry login. |
| `skip_sast` | no | `false` | Skip the SAST step. |
| `skip_sca` | no | `false` | Skip the SCA step. |
| `skip_lint` | no | `false` | Skip the hadolint step. |
| `skip_build` | no | `false` | Skip the Docker build step. |
| `tests_path` | no | `` | Command or script to run inside the container for testing. Defaults to a smoke test. |
| `skip_test` | no | `false` | Skip the container smoke test step. |
| `skip_versioning` | no | `false` | Skip the versioning step. |
| `skip_packaging` | no | `false` | Skip the packaging (image tagging) step. |
| `skip_release` | no | `false` | Skip the release (registry push) step. |
| `skip_reintegration` | no | `false` | Skip the reintegration step. |
| `version_bump` | no | `patch` | Version bump type: patch, minor, or major. |
| `github_token` | no | `` | GitHub token for reintegration. |
| `log_file` | no | `pipery.jsonl` | Path to the JSONL log file. |
| `build_args` | no | `` | Comma-separated list of build args in VAR=val format. |
| `platforms` | no | `linux/amd64` | Platforms to build for. |

## Outputs

No outputs.

## Development

This repository is managed with `pipery-tooling`.

```bash
pipery-actions test --repo .
pipery-actions docs --repo .
pipery-actions release --repo . --dry-run
```

By default, `pipery-actions test --repo .` executes the action against `test-project` and validates `pipery.jsonl`.

## Marketplace Release Flow

1. Update the implementation and changelog.
2. Run `pipery-actions release --repo .`.
3. Push the created git tag and major tag alias.
4. Publish the GitHub release.
