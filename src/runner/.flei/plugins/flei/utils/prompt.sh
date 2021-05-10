flei_prompt() {
  local PROMPT_TEXT
  PROMPT_TEXT="$(echo -e "${1}\n> ")"
  local USER_INPUT

  flei_require @flei/colors

  read -p "${FLEI_COLOR_BLUE}${PROMPT_TEXT}${FLEI_COLOR_NC}" -r USER_INPUT

  if [ -z "${USER_INPUT}" ]; then
    flei_log_error "Please provide a non empty value.\n"
    flei_prompt "${@}"
    exit 0
  fi

  echo "${USER_INPUT}"
}
