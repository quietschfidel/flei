#!/usr/bin/env bash

set -o errexit
set -o pipefail

SCRIPT_DIR="$(cd `dirname ${0}` && pwd)"
FLEI_RC_PATH="${SCRIPT_DIR}/.fleirc"

source "${FLEI_RC_PATH}"
if [ -z "${FLEI_IMAGE}" ]; then
  docker pull ghcr.io/quietschfidel/flei:latest
  FLEI_IMAGE="$(docker inspect --format="{{index .RepoDigests 0}}" ghcr.io/quietschfidel/flei)"
  echo "FLEI_IMAGE=\"${FLEI_IMAGE}\"" >> "${FLEI_RC_PATH}"
fi

if [ ! -d "${SCRIPT_DIR}/.flei" ]; then
  echo "Initializing Flei..."
  docker run --rm -ti \
    -u $(id -u ${USER}):$(id -g ${USER}) \
    -v "${SCRIPT_DIR}/../":/opt/flei-project-root \
    "${FLEI_IMAGE}" \
    flei install
fi

exec "${SCRIPT_DIR}/.flei/main.sh" "${@:1}"
