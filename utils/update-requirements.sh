#!/usr/bin/env bash
# update-requirements: utility script to regenerate requirements files
# This script automatically determines the latest acceptable versions of all
# abstract requirements (those listed in `setup.cfg`) and rewrites all of the
# requirements files accordingly.
# Review the documentation on dependency management for more details:
#   documentation/development-practices.md#dependency-management

set -euo pipefail
# Change directory to project root.
cd "$(dirname "$0")/.."

export MSYS_NO_PATHCONV=1

# Create a container from the Dockerfile's base image, with a long `sleep` as the main process.
# This image might eventually be computed from Dockerfile.
container="$(docker create python:3.9.8-bullseye sleep 600)"
docker start "$container" >/dev/null
# Ensure that the myproj library directory exists so that Pip doesn't complain.
docker exec "$container" mkdir -p /app/myproj
# Copy in the files that define abstract dependencies.
docker cp pyproject.toml "$container":/app
docker cp setup.cfg "$container":/app

update_requirements () {
    type_name="$1"
    file_name="$2"
    extras="$3"
    docker exec "$container" python -m pip install "/app$extras"
    echo -n "# $file_name: pinned myproj dependencies for $type_name
# This file is auto-generated. To regenerate: docker/update-requirements.sh
$(docker exec "$container" python -m pip freeze | grep -v "^myproj @")
" >"$file_name"
}

# Reuse the same container for both requirements files, handling the
# production dependencies first since they are a subset of development.
update_requirements production requirements.txt ""
update_requirements development requirements-dev.txt "[dev]"

# Clean up the container.
docker rm -f "$container" >/dev/null

echo -n "
Requirements files have been regenerated. Review and edit as needed,
run tests, and commit.
Direct dependencies may not be at the latest version due to known issues,
documented in setup.cfg (eventually pyproject.toml).
Transitive dependencies may not be at the latest version due to known
limitations from direct dependencies:
  - currently none
"
