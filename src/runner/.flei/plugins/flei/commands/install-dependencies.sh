flei_command() {
  flei_require @flei/common-paths
  local FLEI_PROJECT_ROOT="$(flei_project_root)"

   docker run --rm -ti \
      -u $(id -u ${USER}):$(id -g ${USER}) \
      -v "${FLEI_PROJECT_ROOT}":"/opt/flei-project-root" \
      -e FLEI_BASE_DIRECTORY="/opt/flei-project-root/flei" \
      ghcr.io/quietschfidel/flei:latest \
      flei install-dependencies
}
