#! /usr/bin/env bash
set -e

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && cd ../.. && pwd)"
cd "${PROJECT_ROOT}"

DOMAIN=backend \
  docker-compose \
  -f docker/docker-compose.deploy.yml \
  -f docker/docker-compose.shared.yml \
  -f docker/docker-compose.test.yml \
  config >docker/docker-stack.yml

docker-compose -f docker/docker-stack.yml build
docker-compose -f docker/docker-stack.yml down -v --remove-orphans # Remove possibly previous broken stacks left hanging after an error
docker-compose -f docker/docker-stack.yml up -d
docker-compose -f docker/docker-stack.yml exec -T backend-tests /tests-start.sh
docker-compose -f docker/docker-stack.yml down -v --remove-orphans
