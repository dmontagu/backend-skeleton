#! /usr/bin/env bash
set -e

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && cd .. && pwd)"
cd "${PROJECT_ROOT}"

NAMESPACE="example-org"
IMAGE_NAME="app-base"

docker build --target build -t "${NAMESPACE}/${IMAGE_NAME}-build" -f ./backend/dockerfiles/app-base.dockerfile ./backend
docker build --target output -t "${NAMESPACE}/${IMAGE_NAME}" -f ./backend/dockerfiles/app-base.dockerfile ./backend
docker-compose build
