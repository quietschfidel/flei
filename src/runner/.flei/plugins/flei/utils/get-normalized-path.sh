flei_get_normalized_path() {
  # from https://stackoverflow.com/a/284671
  # we want to also normalize paths that don't
  # exist for readable error messages
  readlink -m ${1}
}