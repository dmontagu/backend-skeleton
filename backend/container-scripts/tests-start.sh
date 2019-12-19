#! /usr/bin/env bash
GREEN='\033[0;32m'
NC='\033[0m' # No Color
BOLD="\033[1m"
OFF="\033[m"

set -ex

python /app/tests/tests_pre_start.py
pytest --cov=app "$@" tests/

{ set +x; } 2>/dev/null
echo "Executed pytest --cov=app $* tests/"
echo -e "🐍 ${GREEN}${BOLD}All tests passed!${OFF}${NC} 🚀"
