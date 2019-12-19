#! /usr/bin/env bash

# TODO: Convert this to being a click-based CLI using a docker client library
set -e

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && cd ../.. && pwd)"
cd "${PROJECT_ROOT}"

CMDNAME=${0##*/}

SERVICE_NAME=""
STACK_MODE=""
STACK_NAME="compose"
CONTAINER_ID=""

usage() {
  exitcode="$1"
  cat <<USAGE >&2

Get the ID of a container for the specified service

Usage:
  $CMDNAME --service SERVICE_NAME --mode STACK_MODE [--stack STACK_NAME]

Options:
  --service SERVICE_NAME   The name of the service to get a container ID for
  --mode STACK_MODE        Should be "stack" or "compose"
  --stack STACK_NAME       If mode is "stack", the name of the stack (otherwise, it is ignored)
  -h, --help               Show this message
USAGE
  exit "$exitcode"
}

main() {
  if [ -z "$SERVICE_NAME" ]; then
    echo "Must provide a service name"
    usage 1
  fi
  if [ $STACK_MODE != "compose" ] && [ $STACK_MODE != "stack" ]; then
    echo 'mode must be "compose" or "stack"'
    usage 1
  fi
  if [ $STACK_MODE == "stack" ]; then
    if [ -z "$STACK_NAME" ] || [ "$STACK_NAME" == "compose" ]; then
      echo "a stack name must be specified"
      usage 1
    fi
    CONTAINER_ID=$(get_stack_container_id)
  else
    CONTAINER_ID=$(docker-compose ps -q "$SERVICE_NAME")
  fi
  if [ -z "$CONTAINER_ID" ]; then
    echo "No matching container found."
    exit 1
  fi
  echo "$CONTAINER_ID"
}

get_stack_container_id() {
  STACK_CONTAINER_NAME=${STACK_NAME}_${SERVICE_NAME}
  STACK_CONTAINER_IDS=$(
    docker stack ps "$STACK_NAME" --filter "desired-state=running" --filter "name=$STACK_CONTAINER_NAME" -q --no-trunc
  )
  STACK_CONTAINER_ID=$(echo "$STACK_CONTAINER_IDS" | head -n 1)
  echo "${STACK_CONTAINER_NAME}".1."${STACK_CONTAINER_ID}"
}

while [ $# -gt 0 ]; do
  case "$1" in
  --service)
    SERVICE_NAME="$2"
    shift 2
    ;;
  --mode)
    STACK_MODE="$2"
    shift 2
    ;;
  --stack)
    STACK_NAME="$2"
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
