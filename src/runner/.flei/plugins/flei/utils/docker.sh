flei_docker_get_compose_project_name() {
  flei_get_clean_project_name
}

flei_docker() {
  flei_require @flei/resolve-path
  flei_require @flei/common-paths
  flei_require @flei/get-project-name

  local DOCKER_COMPOSE_PATH="$(flei_resolve_path "${1}" "/docker/" "${BASH_SOURCE[1]}" ".docker-compose.yml")"

  export RUN_UID="$(id -u)"
  export RUN_GID="$(id -g)"
  export FLEI_PROJECT_ROOT="$(flei_project_root)"

  export COMPOSE_PROJECT_NAME="$(flei_docker_get_compose_project_name)"

  local DOCKER_COMPOSE_CONFIG=$(docker-compose -f "${DOCKER_COMPOSE_PATH}" config)
  local VOLUMES="$(echo "${DOCKER_COMPOSE_CONFIG}" | docker run --rm -i -u "${RUN_UID}:${RUN_GID}" \
      ghcr.io/quietschfidel/flei:latest \
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
DOCKER_COMPOSE="
services:
  fix-volume-owner:
    image: ghcr.io/quietschfidel/flei:latest
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
