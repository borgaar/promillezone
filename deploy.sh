#!/usr/bin/env bash

set -e

COMMIT_HASH=$(git rev-parse --short HEAD)

echo "-> Building new Docker image"
docker build --no-cache -t promille.zone:$COMMIT_HASH .

echo "-> Migrating database"
prisma migrate deploy

echo "-> Stopping and removing old container"
docker rm -f promille.zone || true

echo "-> Starting new container"
docker run --env-file .env -p 2808:3000 --name promille.zone --restart unless-stopped -d promille.zone:$COMMIT_HASH
