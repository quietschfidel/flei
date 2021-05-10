flei_check_value() {
  local VALUE_TO_CHECK="${1}"
  local ERROR_TEXT="${2}"

  flei_require @flei/logger

  if [ -z "${VALUE_TO_CHECK}" ]; then
    flei_log_error "${ERROR_TEXT}"
    exit 1
  fi
}
