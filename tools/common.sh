#!/usr/bin/env bash

exit_on_error() {
  local err_msg="${1:-}"
  [[ -n "${err_msg}" ]] || err_msg="Unspecified error occurred."
  echo >&2 "${err_msg}"
  exit 1
}

normalize_path() {
  local path="${1}"
  if [[ -d "${path}" ]]; then
    local dirname="${path}"
  else
    local dirname="$(dirname "${path}")"
    local basename="$(basename "${path}")"
  fi
  dirname="$(cd "${dirname}" > /dev/null && pwd)"
  if [[ -z "${basename:-}" ]]; then
    echo "${dirname}"
  else
    echo "${dirname}/${basename}"
  fi
}

# Lovingly inspired by https://unix.stackexchange.com/a/13474.
upsearch() {
  local target_file="${1}"
  slashes=${PWD//[^\/]/}
  directory="$PWD"
  for (( n=${#slashes}; n>0; --n ))
  do
    local test_path="${directory}/${target_file}"
    test -e "${test_path}" && \
      normalize_path "${test_path}" && \
      return 
    directory="${directory}/.."
  done
}

sort_items() {
  local IFS=$'\n'
  sort -u <<<"$*"
}

print_by_line() {
  for item in "${@:-}" ; do
    echo "${item}"
  done
}

