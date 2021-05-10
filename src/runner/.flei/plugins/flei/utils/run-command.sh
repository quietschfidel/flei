flei_run_command_with_context() {
  flei_require @flei/common-paths
  local FLEI_ROOT_DIR
  FLEI_ROOT_DIR="$(flei_root_dir)"

  # run in subshell to prevent leakage of functions/variables as good as possible
  (bash "${FLEI_ROOT_DIR}/.flei/command-runner.sh" "${1}" "${2}" "${@:3}")
}

flei_run_command() {
  flei_run_command_with_context "${1}" "${BASH_SOURCE[1]}" "${@:2}"
}
