flei_run_command_with_context() {
  local FLEI_BASE_UTILS_DIR="$(cd `dirname ${BASH_SOURCE[0]}` && pwd)"
  local FLEI_ROOT_DIR="${FLEI_BASE_UTILS_DIR}/../../.."

  # run in subshell to prevent leakage of functions/variables as good as possible
  (bash "${FLEI_ROOT_DIR}/command-runner.sh" "${1}" "${2}" "${@:3}")
}

flei_run_command() {
  flei_run_command_with_context "${1}" "${BASH_SOURCE[1]}" "${@:2}"
}
