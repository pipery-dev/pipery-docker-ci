# Using Pipery Docker CI

CI pipeline for Docker: lint (hadolint), SAST, SCA, build, test, versioning, push image, reintegration

## Recommended workflow

1. Pin the action to a major tag in production workflows.
2. Keep a representative test project in the repository and point `test_project_path` at it.
3. Emit a `pipery.jsonl` build log during the action run and keep `test_log_path` pointed at it.
4. Make the action consume that path via the configured test input.
5. Keep changelog entries under `## [Unreleased]` until you cut a release.
6. Regenerate docs before publishing a new version.

## Example

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
