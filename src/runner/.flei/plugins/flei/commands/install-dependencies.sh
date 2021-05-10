flei_command() {
  flei_require @flei/common-paths
  flei_require @flei/get-flei-image

  local FLEI_PROJECT_ROOT
  local FLEI_IMAGE
  FLEI_PROJECT_ROOT="$(flei_project_root)"
  FLEI_IMAGE="$(flei_get_flei_image)"

  docker run --rm -ti \
      -u $(id -u ${USER}):$(id -g ${USER}) \
      -v "${FLEI_PROJECT_ROOT}":"/opt/flei-project-root" \
      -e FLEI_BASE_DIRECTORY="/opt/flei-project-root/flei" \
      "${FLEI_IMAGE}" \
      flei install-dependencies
}
