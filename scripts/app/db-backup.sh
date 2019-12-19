#! /usr/bin/env bash
set -e

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && cd ../.. && pwd)"
cd "${PROJECT_ROOT}"

CMDNAME=${0##*/}
DATABASE="app"

usage() {
  exitcode="$1"
  cat <<USAGE >&2

Generate a timestamped backup of the stack database

Usage:
  $CMDNAME --mode STACK_MODE [--stack STACK_NAME] [-d DATABASE]

Options:
  --mode STACK_MODE         Should be "stack" or "compose"
  --stack STACK_NAME        If mode is "stack", the name of the stack (otherwise, it is ignored)
  -d, --database DATABASE   Name of database to use (default: $DATABASE)
  -h, --help                Show this message
USAGE
  exit "$exitcode"
}

main() {
  ./scripts/util/database/dump.sh -o data/dump_backup_latest.sql --mode "$STACK_MODE" --stack "$STACK_NAME"
  cp data/dump_backup_latest.sql data/dump_backup_"$(date +%Y-%m-%d"_"%H_%M_%S)".sql
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
