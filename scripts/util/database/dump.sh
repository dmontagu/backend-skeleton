#! /usr/bin/env bash
set -e

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && cd ../../.. && pwd)"
cd "${PROJECT_ROOT}"

CMDNAME=${0##*/}

OUTPUT_FILE=""
STACK_MODE=""
STACK_NAME="compose"
DATABASE="app"

CONTAINER_ID=""

usage() {
  exitcode="$1"
  cat <<USAGE >&2

Dump the stack's database to a specified output file

Usage:
  $CMDNAME -o OUTPUT_FILE --mode STACK_MODE [--stack STACK_NAME] [-d DATABASE]

Options:
  -o, --output OUTPUT_FILE  Destination file for dump (relative to project root)
  --mode STACK_MODE         Should be "stack" or "compose"
  --stack STACK_NAME        If mode is "stack", the name of the stack (otherwise, it is ignored)
  -d, --database DATABASE   Name of database to use (default: $DATABASE)
  -h, --help                Show this message
USAGE
  exit "$exitcode"
}

main() {
  validate_inputs
  get_container_id
  dump_database
  echo "Database dump complete! 🗄🗄"
}

validate_inputs() {
  if [ -z "$OUTPUT_FILE" ]; then
    echo "-f argument is required"
    usage 1
  fi
}

get_container_id() {
  CONTAINER_ID=$(./scripts/util/get-container-id.sh --service db --mode "$STACK_MODE" --stack "$STACK_NAME")
  if [ -z "$CONTAINER_ID" ]; then
    echo "Failed to obtain a container ID"
    exit 1
  fi
}

dump_database() {
  docker exec "$CONTAINER_ID" pg_dump \
    --dbname="$DATABASE" \
    --format=plain \
    --clean \
    --no-owner \
    >"$OUTPUT_FILE"
}

while [ $# -gt 0 ]; do
  case "$1" in
  --mode)
    STACK_MODE="$2"
    shift 2
    ;;
  --stack)
    STACK_NAME="$2"
    shift 2
    ;;
  -o | --output)
    OUTPUT_FILE="$2"
    shift 2
    ;;
  -d | --database)
    DATABASE="$2"
    shift 2
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
