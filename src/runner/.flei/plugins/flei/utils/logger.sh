flei_log_error() {
  # we can not use flei_require here, because of circular dependency issues
  local FLEI_CORE_PLUGIN_UTILS_DIR="$(cd `dirname ${BASH_SOURCE[0]}` && pwd)"
  source "${FLEI_CORE_PLUGIN_UTILS_DIR}/colors.sh"

  (>&2 printf "${FLEI_COLOR_RED}${1}${FLEI_COLOR_NC}\n")
}

flei_log_notice() {
  # we can not use flei_require here, because of circular dependency issues
  local FLEI_CORE_PLUGIN_UTILS_DIR="$(cd `dirname ${BASH_SOURCE[0]}` && pwd)"
  source "${FLEI_CORE_PLUGIN_UTILS_DIR}/colors.sh"

  (>&2 printf "${FLEI_COLOR_LIGHT_GREY}${1}${FLEI_COLOR_NC}\n")
}
