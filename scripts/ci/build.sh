#! /usr/bin/env bash
set -e

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && cd ../.. && pwd)"

set -x
cd "${PROJECT_ROOT}"

DOCKER_TAG=${DOCKER_TAG:-latest} \
  DOCKER_IMAGE_BACKEND=${DOCKER_IMAGE_BACKEND:?DOCKER_IMAGE_BACKEND not set} \
  DOCKER_IMAGE_DB=${DOCKER_IMAGE_DB:?$DOCKER_IMAGE_DB not set} \
  docker-compose \
  -f docker/docker-compose.deploy.images.yml \
  -f docker/docker-compose.shared.build.yml \
  config >docker/docker-stack.yml

docker-compose -f docker/docker-stack.yml build
