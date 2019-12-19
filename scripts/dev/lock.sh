#!/usr/bin/env bash
set -e

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && cd ../.. && pwd)"
APP_ROOT=${PROJECT_ROOT}/backend/app

set -x
cd "${APP_ROOT}"
poetry lock
poetry export -f requirements.txt >requirements_tmp.txt
mv requirements_tmp.txt requirements.txt
