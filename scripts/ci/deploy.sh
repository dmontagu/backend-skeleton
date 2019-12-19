#! /usr/bin/env bash
set -e

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && cd ../.. && pwd)"
cd "${PROJECT_ROOT}"

CMDNAME=${0##*/}

# Required args
DOMAIN=""
STACK_NAME=""
EMAIL=""
HASHED_PW=""

# Optional args
AUTO_LABEL="YES"
DEPLOY="YES"
USERNAME="admin"
TRAEFIK_TAG="traefik-public-tag"
DOCKER_TAG="latest"

# Undocumented args?
DOCKER_IMAGE_BACKEND=${DOCKER_IMAGE_BACKEND:?DOCKER_IMAGE_BACKEND not set}
DOCKER_IMAGE_DB=${DOCKER_IMAGE_DB:?$DOCKER_IMAGE_DB not set}

usage() {
  exitcode="$1"
  cat <<USAGE >&2
Generate, label, and deploy a composed docker stack

Usage:
  $CMDNAME -d DOMAIN -s STACK_NAME -e EMAIL -p HASHED_PW
    [--username USERNAME] [--traefik-tag TRAEFIK_TAG] [--docker-tag DOCKER_TAG]
    [--no-auto-label] [--no-deploy]

Options:
  -d, --domain DOMAIN         Domain name to use
  -s, --stack STACK_NAME      Stack name to use
  -e, --email EMAIL           Email to use for Let's Encrypt
  -p, --hashed-pw HASHED_PW   Hashed password for use with traefik basic auth

  --username USERNAME         Username for use with traefik basic auth (default: $USERNAME)
  --traefik-tag TRAEFIK_TAG   Traefik tag to use (default: $TRAEFIK_TAG)
  --docker-tag DOCKER_TAG     Docker tag to use for backend image (default: $DOCKER_TAG)

  --no-auto-label             Don't run docker-auto-labels
  --no-deploy                 Don't run docker stack deploy

  -h, --help                  Show this message
USAGE
  exit "$exitcode"
}

error() {
  echo "ERROR: $1"
  echo ""
  usage 1
}

main() {
  validate_args
  generate_stack_yml
  if [ -n "$AUTO_LABEL" ]; then
    docker-auto-labels docker/docker-stack.yml
  fi
  if [ -n "$DEPLOY" ]; then
    docker stack deploy -c docker/docker-stack.yml --with-registry-auth "${STACK_NAME}"
  fi
}

validate_args() {
  if [ -z "$DOMAIN" ]; then
    error "--domain argument is required"
  fi
  if [ -z "$STACK_NAME" ]; then
    error "--stack argument is required"
  fi
  if [ -z "$EMAIL" ]; then
    error "--email argument is required"
  fi
  if [ -z "$HASHED_PW" ]; then
    error "--hashed-pw argument is required"
  fi
}

generate_stack_yml() {
  DOMAIN=${DOMAIN} \
    STACK_NAME=${STACK_NAME} \
    EMAIL=${EMAIL} \
    HASHED_PASSWORD=${HASHED_PW} \
    USERNAME=${USERNAME} \
    TRAEFIK_TAG=${TRAEFIK_TAG} \
    DOCKER_TAG=${DOCKER_TAG} \
    DOCKER_IMAGE_BACKEND=$DOCKER_IMAGE_BACKEND \
    DOCKER_IMAGE_DB=$DOCKER_IMAGE_DB \
    docker-compose \
    -f docker/docker-compose.deploy.labels.yml \
    -f docker/docker-compose.deploy.yml \
    -f docker/docker-compose.shared.yml \
    config >docker/docker-stack.yml
}

while [ $# -gt 0 ]; do
  case "$1" in
  -d | --domain)
    DOMAIN="$2"
    shift 2
    ;;
  -s | --stack)
    STACK_NAME="$2"
    shift 2
    ;;
  -e | --email)
    EMAIL="$2"
    shift 2
    ;;
  -p | --hashed-pw)
    HASHED_PW="$2"
    shift 2
    ;;
  --username)
    DOMAIN="$2"
    shift 2
    ;;
  --traefik-tag)
    TRAEFIK_TAG="$2"
    shift 2
    ;;
  --docker-tag)
    DOCKER_TAG="$2"
    shift 2
    ;;
  --no-auto-label)
    AUTO_LABEL=""
    shift 1
    ;;
  --no-deploy)
    DEPLOY=""
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
