flei_resolve_path() {
  local PATH_TO_RESOLVE="${1}"
  local FLEI_DIRECTORY_PREFIX="${2:-/}"
  local CALLING_FILE="${3:-"${BASH_SOURCE[1]}"}"
  local FLEI_BASE_UTILS_DIR="$(cd `dirname ${BASH_SOURCE[0]}` && pwd)"
  local FLEI_BASE_DIR="${FLEI_BASE_UTILS_DIR}/.."
  local FLEI_CORE_PLUGIN_UTILS_DIR="${FLEI_BASE_DIR}/plugins/flei/utils"
  local BASE_PATH_FOR_RELATIVE_REQUIRE="$(cd `dirname ${CALLING_FILE}` && pwd)"
  local PLUGIN_PREFIX="@"
  local ABSOLUTE_PATH_PREFIX="/"
  local RELATIVE_PATH_PREFIX="./"
  local FILE_SUFFIX=".sh"
  local RESOLVE_SUFFIX=$([ "${PATH_TO_RESOLVE: -3}" == "${FILE_SUFFIX}" ] && echo "" || echo "${FILE_SUFFIX}")

  source "${FLEI_CORE_PLUGIN_UTILS_DIR}/get-normalized-path.sh"

  # inspired by https://stackoverflow.com/a/5257398
  local SPLITTED_PATH_TO_RESOLVE=(${PATH_TO_RESOLVE/\// })

  if [ "${PATH_TO_RESOLVE:0:1}" == "${PLUGIN_PREFIX}" ]; then
    local RESOLVED_PATH="${FLEI_BASE_DIR}/plugins/${SPLITTED_PATH_TO_RESOLVE[0]:1}${FLEI_DIRECTORY_PREFIX}${SPLITTED_PATH_TO_RESOLVE[1]}${RESOLVE_SUFFIX}"
    echo "$(flei_get_normalized_path "${RESOLVED_PATH}")"
    exit 0
  fi

  if [ "${PATH_TO_RESOLVE:0:1}" == "${ABSOLUTE_PATH_PREFIX}" ]; then
    local RESOLVED_PATH="${PATH_TO_RESOLVE}${RESOLVE_SUFFIX}"
    echo "$(flei_get_normalized_path "${RESOLVED_PATH}")"
    exit 0
  fi

  if [ "${PATH_TO_RESOLVE:0:2}" == "${RELATIVE_PATH_PREFIX}" ]; then
    local RESOLVED_PATH="${BASE_PATH_FOR_RELATIVE_REQUIRE}/${PATH_TO_RESOLVE}${RESOLVE_SUFFIX}"
    echo "$(flei_get_normalized_path "${RESOLVED_PATH}")"
    exit 0
  fi

  local RESOLVED_PATH="${FLEI_BASE_DIR}/..${FLEI_DIRECTORY_PREFIX}${PATH_TO_RESOLVE}${RESOLVE_SUFFIX}"
  echo "$(flei_get_normalized_path "${RESOLVED_PATH}")"
}