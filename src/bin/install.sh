#!/usr/bin/env bash

set -o errexit
set -o pipefail

if [ ! -d "${FLEI_PROJECT_ROOT}" ]; then
  echo "Please mount a target directory to ${FLEI_PROJECT_ROOT}"
  exit 1
fi

FLEI_TARGET_DIRECTORY="${FLEI_PROJECT_ROOT}/flei"

mkdir -p "${FLEI_TARGET_DIRECTORY}"
rm -rf "${FLEI_TARGET_DIRECTORY}/.flei"
cp -r "${FLEI_ROOT_PATH}/runner/." "${FLEI_TARGET_DIRECTORY}"
cp "${FLEI_ROOT_PATH}/.gitignore.template" "${FLEI_TARGET_DIRECTORY}/.gitignore"
touch "${FLEI_TARGET_DIRECTORY}/flei.yaml"
touch "${FLEI_TARGET_DIRECTORY}/plugins-lock.yaml"
touch "${FLEI_TARGET_DIRECTORY}/.fleirc"
