flei_get_flei_image() {
  flei_require @flei/config
  flei_require @flei/validate

  local FLEI_IMAGE_NAME
  FLEI_IMAGE_NAME="$(flei_get_config ".fleirc" "FLEI_IMAGE")"
  flei_check_value "${FLEI_IMAGE_NAME}" "FLEI_IMAGE is not set in .fleirc. Please ensure that it's set."
  echo "${FLEI_IMAGE_NAME}"
}
