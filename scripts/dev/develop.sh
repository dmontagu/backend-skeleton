#!/usr/bin/env bash
set -e

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && cd ../.. && pwd)"
cd "${PROJECT_ROOT}"

./scripts/util/check-requirements.sh

APP_ROOT=${PROJECT_ROOT}/backend/app

set -x
cd "${APP_ROOT}"
poetry run pip install -r requirements.txt
poetry install

{ set +x; } 2>/dev/null
echo ""
echo "Virtual environment interpreter installed at:"
poetry run python -c "import sys; print(sys.executable)"
