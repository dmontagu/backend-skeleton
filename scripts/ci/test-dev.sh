#! /usr/bin/env bash
set -e

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && cd ../.. && pwd)"
cd "${PROJECT_ROOT}"

if [ "$(uname -s)" = "Linux" ]; then
  echo "Removing __pycache__ files"
  sudo find . -type d -name __pycache__ -exec rm -r {} \+
fi

docker-compose \
  -f docker/docker-compose.dev.yml \
  -f docker/docker-compose.shared.yml \
  -f docker/docker-compose.test.yml \
  config >docker/docker-stack.yml

docker-compose -f docker/docker-stack.yml build
docker-compose -f docker/docker-stack.yml down -v --remove-orphans
docker-compose -f docker/docker-stack.yml up -d
docker-compose -f docker/docker-stack.yml exec -T backend-tests /tests-start.sh
