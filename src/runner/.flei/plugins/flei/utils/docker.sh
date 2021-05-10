flei_docker_get_compose_project_name() {
  flei_get_clean_project_name
}

flei_get_docker_compose_path() {
  flei_require @flei/common-paths
  flei_require @flei/get-flei-image

  local FLEI_IMAGE
  FLEI_IMAGE="$(flei_get_flei_image)"

  local DOCKER_COMPOSE_PATH_BASE
  DOCKER_COMPOSE_PATH_BASE="$(flei_resolve_path "${1}" "/docker/" "${BASH_SOURCE[1]}" ".docker-compose")"
  local DOCKER_COMPOSE_PATH_YML="${DOCKER_COMPOSE_PATH_BASE}.yml"
  local DOCKER_COMPOSE_PATH_JS="${DOCKER_COMPOSE_PATH_BASE}.js"
  local DOCKER_COMPOSE_PATH_GENERATED="${DOCKER_COMPOSE_PATH_BASE}.js.yml"

  if [ -f "${DOCKER_COMPOSE_PATH_JS}" ]; then
    local PROJECT_ROOT
    PROJECT_ROOT="$(flei_project_root)"
    local PROJECT_ROOT_IN_DOCKER="/opt/flei-project-root"
    local DOCKER_COMPOSE_RELATIVE_TO_PROJECT_ROOT="${DOCKER_COMPOSE_PATH_JS#"${PROJECT_ROOT}/"}"
    local DOCKER_COMPOSE_PATH_IN_DOCKER="${PROJECT_ROOT_IN_DOCKER}/${DOCKER_COMPOSE_RELATIVE_TO_PROJECT_ROOT}"
    docker run --rm -i -u "${RUN_UID}:${RUN_GID}" \
      -v "${PROJECT_ROOT}:${PROJECT_ROOT_IN_DOCKER}" \
      "${FLEI_IMAGE}" \
      flei generate-docker-compose-config-from-js "${DOCKER_COMPOSE_PATH_IN_DOCKER}"
    echo "${DOCKER_COMPOSE_PATH_GENERATED}"
    exit 0
  fi

  echo "${DOCKER_COMPOSE_PATH_YML}"
}

flei_docker() {
  flei_require @flei/resolve-path
  flei_require @flei/common-paths
  flei_require @flei/get-project-name
  flei_require @flei/get-flei-image

  local FLEI_IMAGE
  FLEI_IMAGE="$(flei_get_flei_image)"

  export RUN_UID
  RUN_UID="$(id -u)"
  export RUN_GID
  RUN_GID="$(id -g)"
  export FLEI_PROJECT_ROOT
  FLEI_PROJECT_ROOT="$(flei_project_root)"

  local DOCKER_COMPOSE_PATH
  DOCKER_COMPOSE_PATH="$(flei_get_docker_compose_path "${@}")"

  export COMPOSE_PROJECT_NAME
  COMPOSE_PROJECT_NAME="$(flei_docker_get_compose_project_name)"

  local DOCKER_COMPOSE_CONFIG
  DOCKER_COMPOSE_CONFIG=$(docker-compose -f "${DOCKER_COMPOSE_PATH}" config)

  local VOLUMES
  VOLUMES="$(echo "${DOCKER_COMPOSE_CONFIG}" | docker run --rm -i -u "${RUN_UID}:${RUN_GID}" \
      "${FLEI_IMAGE}" \
      flei get-volumes-from-docker-compose-config)"

  flei_docker_fix_volume_owner "${VOLUMES}"

  set +o errexit
  docker-compose -f "${DOCKER_COMPOSE_PATH}" run --rm "${@:2}"
  DOCKER_EXIT_CODE=$?
  set -o errexit

  docker-compose -f "${DOCKER_COMPOSE_PATH}" down

  if [ ${DOCKER_EXIT_CODE} -ne 0 ]; then
    exit ${DOCKER_EXIT_CODE}
  fi
}

function flei_docker_fix_volume_owner_generate_service_volumes() {
  for var in "$@"; do
      echo "      - ${var}:/opt/flei-fix-volume-owner/${var}"
  done
}

function flei_docker_fix_volume_owner_generate_volume_configuration() {
  for var in "$@"; do
      echo "  ${var}:"
  done
}

flei_docker_fix_volume_owner() {
  flei_require @flei/get-flei-image

  local FLEI_IMAGE
  FLEI_IMAGE="$(flei_get_flei_image)"

DOCKER_COMPOSE="
services:
  fix-volume-owner:
    image: ${FLEI_IMAGE}
    volumes:
$(flei_docker_fix_volume_owner_generate_service_volumes "${@}")
    command: |
      sh -c \"chown ${RUN_UID}:${RUN_GID} /opt/flei-fix-volume-owner/*\"
volumes:
$(flei_docker_fix_volume_owner_generate_volume_configuration "${@}")
"

  echo "${DOCKER_COMPOSE}" | docker-compose -f - run --rm fix-volume-owner
  echo "${DOCKER_COMPOSE}" | docker-compose -f - down
}
