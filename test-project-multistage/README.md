# test-project-multistage

A multi-stage Docker build fixture used to verify that the pipery-docker-ci action correctly handles multi-stage Dockerfiles.

## Stages

- **builder**: Installs bash and runs `build.sh` to produce an artifact at `/app/output`.
- **runtime**: Copies only the artifact from the builder stage, keeping the final image small.

## Usage

```bash
docker build --load -t test-multistage-pipery .
docker run --rm test-multistage-pipery
```
