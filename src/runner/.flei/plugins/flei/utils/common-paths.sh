flei_root_dir() {
  flei_require @flei/get-normalized-path
  local FLEI_BASE_UTILS_DIR="$(cd `dirname ${BASH_SOURCE[0]}` && pwd)"
  echo $(flei_get_normalized_path "${FLEI_BASE_UTILS_DIR}/../../../..")
}

flei_project_root() {
  flei_require @flei/get-normalized-path
  echo $(flei_get_normalized_path "$(flei_root_dir)/..")
}
