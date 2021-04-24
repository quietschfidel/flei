#!/usr/bin/env bash

set -o errexit
set -o pipefail

SCRIPT_DIR="$(cd `dirname ${0}` && pwd)"

if [ ! -d "${SCRIPT_DIR}/.flei" ]; then
  echo "Initializing Flei..."
  docker run --rm -ti \
    -u $(id -u ${USER}):$(id -g ${USER}) \
    -v "${SCRIPT_DIR}/../":/opt/flei-project-root \
    ghcr.io/quietschfidel/flei:latest \
    flei install
fi

exec "${SCRIPT_DIR}/.flei/main.sh" "${@:1}"
