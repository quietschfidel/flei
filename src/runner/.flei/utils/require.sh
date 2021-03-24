flei_require() {
  local FLEI_BASE_UTILS_DIR="$(cd `dirname ${BASH_SOURCE[0]}` && pwd)"
  local FLEI_CORE_PLUGIN_UTILS_DIR="${FLEI_BASE_UTILS_DIR}/../plugins/flei/utils"

  source "${FLEI_CORE_PLUGIN_UTILS_DIR}/logger.sh"
  source "${FLEI_BASE_UTILS_DIR}/resolve-path.sh"

  local REQUIRED_FILE="$(flei_resolve_path "${1}" "/utils/" ${BASH_SOURCE[1]})"

  if [ ! -f "${REQUIRED_FILE}" ]; then
    flei_log_error "Require error in ${BASH_SOURCE[1]} for command: 'flei_require ${REQUIRE_PATH}'"
    flei_log_error "File \"${REQUIRED_FILE}\" not found."
    exit 1
  fi

  source "${REQUIRED_FILE}"
}