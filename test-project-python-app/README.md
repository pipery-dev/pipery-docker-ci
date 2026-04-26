# test-project-python-app

A minimal Python application Docker image fixture used to verify that the pipery-docker-ci action correctly builds Python-based images.

## Contents

- `Dockerfile`: Uses `python:3.11-slim`, installs dependencies, and runs `app.py`.
- `requirements.txt`: No external dependencies for this fixture.
- `app.py`: Prints a greeting message.

## Usage

```bash
docker build --load -t test-python-app-pipery .
docker run --rm test-python-app-pipery
```
