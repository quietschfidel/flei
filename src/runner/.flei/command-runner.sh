#!/usr/bin/env bash

set -o errexit
set -o pipefail

FLEI_BASE_DIR="$(cd `dirname ${BASH_SOURCE[0]}` && pwd)"

source "${FLEI_BASE_DIR}/utils/require.sh"
flei_require ./utils/resolve-path
flei_require @flei/logger

COMMAND="${1}"
COMMAND_FILE="$(flei_resolve_path "${COMMAND}" "/commands/" ${2})"

if [ ! -f "${COMMAND_FILE}" ]; then
  flei_log_error "The command \"${COMMAND}\" does not exist."
  flei_log_error "Please create a script with the name \"${COMMAND_FILE}\" to create the command."
  exit 1
fi

source "${COMMAND_FILE}"
TYPE_OF_FLEI_COMMAND_FUNCTION=$(type -t flei_command || echo "")

if [[ "${TYPE_OF_FLEI_COMMAND_FUNCTION}" != "function" ]]; then
  flei_log_error "The command file \"${COMMAND_FILE}\" does not provide a \"flei_command\" entry point."
  flei_log_error "Please check that the file provides a function with the name \"flei_command\"."
  exit 1
fi

flei_command "${@:3}"
