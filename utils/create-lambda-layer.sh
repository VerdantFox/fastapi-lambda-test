#!/usr/bin/env bash
# creates lambda-layer zip file.
# Need to have docker to work

set -euo pipefail

# cd to root of the repo
cd "$(git rev-parse --show-toplevel)"

mkdir -p dist/
rm -f dist/lambda-layer.zip

docker run --mount "type=bind,source=$(pwd),target=/app" python:3.9-bullseye bash -c '
pip install --upgrade pip
pip install /app

mkdir -p /python/lib/python3.9/site-packages/
cp -r /usr/local/lib/python3.9/site-packages /python/lib/python3.9/
apt update
apt install zip
zip -r /app/dist/myproj-lambda-layer.zip /python'
