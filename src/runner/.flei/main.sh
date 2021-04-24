#!/usr/bin/env bash

set -o errexit
set -o pipefail

FLEI_BASE_DIR="$(cd `dirname ${0}` && pwd)"

source "${FLEI_BASE_DIR}/utils/require.sh"
flei_require @flei/logger
flei_require @flei/run-command

flei_run_command @flei/install-dependencies

COMMAND=${1}

if [ -z "${COMMAND}" ]; then
  flei_log_error "You have to provide a command as parameter."
  exit 1
fi

flei_run_command_with_context ${COMMAND} "${FLEI_BASE_DIR}/../commands/${COMMAND}" "${@:2}"
