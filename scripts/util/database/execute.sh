#! /usr/bin/env bash
set -e

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && cd ../../.. && pwd)"
cd "${PROJECT_ROOT}"

CMDNAME=${0##*/}
DATABASE="app"
SQL_FILE=""
TERMINATE_CONNECTIONS=""

usage() {
  exitcode="$1"
  cat <<USAGE >&2
Usage:
  $CMDNAME -f SQL_FILE [-d DATABASE] [-t]

Options:
  -c, --container CONTAINER_ID   Database container ID
  -f, --sql-file SQL_FILE        File containing the plain sql to execute
  -d, --database DATABASE        Name of database to use (default: $DATABASE)
  -t, --terminate                Terminate existing connections to the database
  -h, --help                     Show this message
USAGE
  exit "$exitcode"
}

run_script() {
  validate_inputs
  if [ -n "$TERMINATE_CONNECTIONS" ]; then
    terminate_connections
  fi
  execute_sql
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

terminate_connections() {
  echo "Terminating existing database connections..."
  docker exec "$CONTAINER_ID" psql -U postgres -d "$DATABASE" <<EOF >/dev/null
SELECT pid, pg_terminate_backend(pid)
FROM pg_stat_activity
WHERE datname = current_database() AND pid <> pg_backend_pid();
EOF
}

execute_sql() {
  echo "Executing SQL file..."
  echo "docker exec \"$CONTAINER_ID\" psql -U postgres -d \"$DATABASE\" <\"$SQL_FILE\" >/dev/null"
  docker exec -i "$CONTAINER_ID" psql -U postgres -d "$DATABASE" <"$SQL_FILE" >/dev/null

  echo "SQL execution complete."
}

while [ $# -gt 0 ]; do
  case "$1" in
  -c | --container)
    CONTAINER_ID="$2"
    shift 2
    ;;
  -d | --database)
    DATABASE="$2"
    shift 2
    ;;
  -f | --sql-file)
    SQL_FILE="$2"
    shift 2
    ;;
  -t | --terminate)
    TERMINATE_CONNECTIONS="YES"
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

run_script
