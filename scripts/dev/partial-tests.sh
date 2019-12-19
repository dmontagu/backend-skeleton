#! /usr/bin/env bash
set -e

# Can be used to run a specific test or subset of tests in the backend-tests container
# E.g., via ./partial-tests.sh tests/specific/test.py

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && cd ../.. && pwd)"
cd "${PROJECT_ROOT}"

if [ -z "$*" ]; then
  COMMAND="pytest tests"
else
  COMMAND="pytest $*"
fi

set -x
docker-compose up -d backend-tests >/dev/null 2>&1
docker-compose exec backend-tests bash -c "$COMMAND"
