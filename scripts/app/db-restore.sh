#! /usr/bin/env bash
echo "This script may need to be updated to work with docker stack!"
exit 1
set -e

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && cd ../.. && pwd)"
cd "${PROJECT_ROOT}"

CMDNAME=${0##*/}
SQL_FILE=""
DATABASE="app"
SKIP_CONFIRMATION=""

usage() {
  exitcode="$1"
  cat <<USAGE >&2
Usage:
  $CMDNAME -f SQL_FILE [-d DATABASE]

Options:
  -f, --sql-file SQL_FILE  The file containing the dump to restore
  -d, --database DATABASE  Name of database to use (default: $DATABASE)
  -y, --yes                Skip confirmation
  -h, --help               Show this message
USAGE
  exit "$exitcode"
}

main() {
  validate_inputs
  reset_database
  ./scripts/util/database/execute.sh -f $SQL_FILE
  explain_errors
}

validate_inputs() {
  if [ -z "$SQL_FILE" ]; then
    echo "-f argument is required"
    usage 1
  fi
  if [ ! -f "$SQL_FILE" ]; then
    echo "$SQL_FILE is not a file"
    usage 1
  fi
}

reset_database() {
  if [ -z "$SKIP_CONFIRMATION" ]; then
    confirm "This will reset the database container. Proceed?"
  fi
  ./scripts/dev/reset-database.sh -y
}

explain_errors() {
  cat <<EXPLANATION >&2

******************************************************************************************
******************************************************************************************
You may see lines above starting with "ERROR:" indicating tables and/or types don't exist.

This happens because the tables/types are not present (since the database has been reset).

These errors may be safely ignored.
******************************************************************************************
******************************************************************************************
EXPLANATION
}

confirm() {
  QUESTION=$1
  read -p "$QUESTION y/[n]: " -n 1 -r
  echo "" # (optional) move to a new line
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    exit 1
  fi
}

while [ $# -gt 0 ]; do
  case "$1" in
  -f | --sql-file)
    SQL_FILE="$2"
    shift 2
    ;;
  -d | --database)
    DATABASE="$2"
    shift 2
    ;;
  -y | --yes)
    SKIP_CONFIRMATION="yes"
    shift 1
    ;;
  -h | --help)
    usage 0
    ;;
  *)
    echo "Unknown argument: $1"
    usage 1
    ;;
  esac
done

main
