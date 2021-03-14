flei_require() {
  source "${FLEI_BASE_UTILS_DIR}/logger.sh"
  UTILS_FILE="${FLEI_BASE_UTILS_DIR}/${1}.sh"

  if [ ! -f "${UTILS_FILE}" ]; then
    flei_log_error "A required utils file was not found \"${UTILS_FILE}\"."
    exit 1
  fi

  source "${UTILS_FILE}"
}