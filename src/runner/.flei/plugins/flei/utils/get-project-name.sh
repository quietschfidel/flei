flei_get_project_name() {
  flei_require @flei/config
  flei_ensure_config flei PROJECT_NAME "Project name"
}

flei_get_clean_project_name() {
  local NAME_UNCLEANED
  NAME_UNCLEANED="$(flei_get_project_name)"

  # from https://stackoverflow.com/a/94500
  NAME_WITHOUT_SPACES_UNDERSCORE_AND_SLASHES=${NAME_UNCLEANED//[.\/ _]/-}
  NAME_ALPHANUMERIC=${NAME_WITHOUT_SPACES_UNDERSCORE_AND_SLASHES//[^a-zA-Z0-9-]/}
  NAME_LOWER_CASE=${NAME_ALPHANUMERIC,,}

  echo "${NAME_LOWER_CASE}"
}
