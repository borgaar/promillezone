#!/usr/bin/env bash

set -e

################################
# CONFIGURATION
# Change these values as needed
DOMAIN="promille.zone"
PORT=2808
ENV_FILE_PATH=".env"
################################

COMMIT_HASH=$(git rev-parse --short HEAD)
IMAGE_NAME="$DOMAIN:$COMMIT_HASH"

echo "-> Building new Docker image"
docker build --build-arg CARGO_BUILD_JOBS=3 --no-cache -t $IMAGE_NAME .

echo "-> Migrating database"
cd migration
cargo run --jobs 3 --release -- up

echo "-> Stopping and removing old container"
docker rm -f $DOMAIN || true

echo "-> Starting new container"
docker run --env-file $ENV_FILE_PATH -p $PORT:3000 --name $DOMAIN --restart unless-stopped -d $IMAGE_NAME
