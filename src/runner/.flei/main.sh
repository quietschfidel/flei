#!/usr/bin/env bash

set -o errexit
set -o pipefail

export FLEI_BASE_DIR="$(cd `dirname ${0}` && pwd)"
export FLEI_BASE_UTILS_DIR="${FLEI_BASE_DIR}/utils"
export FLEI_ROOT_DIR="${FLEI_BASE_DIR}/.."
export FLEI_PROJECT_ROOT_DIR="${FLEI_ROOT_DIR}/.."
export FLEI_COMMANDS_DIR="${FLEI_ROOT_DIR}/commands"

source "${FLEI_BASE_UTILS_DIR}/require.sh"
flei_require logger

COMMAND=${1}
COMMAND_FILE="${FLEI_COMMANDS_DIR}/${COMMAND}.sh"

if [ -z "${COMMAND}" ]; then
  flei_log_error "You have to provide a command as parameter."
  exit 1
fi

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

flei_command "${@:2}"
