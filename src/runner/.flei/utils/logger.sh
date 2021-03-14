flei_log_error() {
  flei_require colors
  (>&2 printf "${RED}${1}${NC}\n")
}