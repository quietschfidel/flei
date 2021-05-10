flei_get_config_path() {
  local PATH_TO_RESOLVE=${1:-flei}
  flei_require @flei/common-paths

  if [ "${PATH_TO_RESOLVE:0:6}" == "local/" ]; then
    echo "$(flei_root_dir)/config/local/.env.${PATH_TO_RESOLVE:6}"
    exit 0
  fi

  if [ "${PATH_TO_RESOLVE}" == ".fleirc" ]; then
    echo "$(flei_root_dir)/.fleirc"
    exit 0
  fi

  echo "$(flei_root_dir)/config/.env.${PATH_TO_RESOLVE}"
}

flei_get_config() {
  local CONFIG_FILE_PATH
  CONFIG_FILE_PATH="$(flei_get_config_path "${1}")"
  local VARIABLE_NAME=${2}

  touch "${CONFIG_FILE_PATH}"

  SUBSHELL_COMMAND="
#!/usr/bin/env bash

set -o errexit
set -o pipefail

${VARIABLE_NAME}=\"\"
source \"${CONFIG_FILE_PATH}\"
echo \"\${${VARIABLE_NAME}}\"
"

  bash -c "${SUBSHELL_COMMAND}";
}

flei_ensure_config() {
  local CONFIG_NAME="${1}"
  local CONFIG_FILE_PATH
  CONFIG_FILE_PATH="$(flei_get_config_path "${1}")"
  local VARIABLE_NAME=${2}
  local PROMPT_TEXT=${3}

  flei_require @flei/logger
  flei_require @flei/prompt

  local CURRENT_VALUE
  CURRENT_VALUE=$(flei_get_config "${CONFIG_NAME}" "${VARIABLE_NAME}")

  if [ -z "${CURRENT_VALUE}" ]; then
    local NEW_VALUE
    NEW_VALUE="$(flei_prompt "${PROMPT_TEXT}")"
    echo "${VARIABLE_NAME}=\"${NEW_VALUE}\"" >> "${CONFIG_FILE_PATH}"
    flei_log_notice "Updated config in: ${CONFIG_FILE_PATH}"
    echo "${NEW_VALUE}"
    exit 0
  fi

  echo "${CURRENT_VALUE}"
}
