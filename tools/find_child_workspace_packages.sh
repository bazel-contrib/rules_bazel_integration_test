#!/usr/bin/env bash

# This was lovingly inspired by
# https://github.com/bazelbuild/rules_python/blob/main/tools/bazel_integration_test/update_deleted_packages.sh.

# For integration tests, we want to be able to glob() up the sources inside a nested package
# See explanation in .bazelrc

set -euo pipefail

# MARK - Functions

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
    test -e "${test_path}" && echo "${test_path}" && return 
    directory="${directory}/.."
  done
}

find_bazel_pkgs() {
  local path="${1}"
  find "${path}" \( -name BUILD -or -name BUILD.bazel \) | xargs -n 1 dirname 
}

sort_items() {
  local IFS=$'\n'
  shift
  sort -u <<<"$*"
}

print_by_line() {
  for item in "${@}" ; do
    echo "${item}"
  done
}

# MARK - Main

script_dir="$(normalize_path "${BASH_SOURCE[0]}")"
starting_dir=$(pwd)

# Make sure that we end up back in the original directory.
cleanup() {
  cd "${starting_dir}"
}
trap cleanup EXIT

# Process args
while (("$#")); do
  case "${1}" in
    "--workspace")
      workspace_root="${2}"
      shift 2
      ;;
    *)
      shift 1 ;;
  esac
done

[[ -z "${workspace_root:-}" ]] && [[ ! -z "${BUILD_WORKING_DIRECTORY:-}"  ]] && workspace_root="${BUILD_WORKING_DIRECTORY:-}"
[[ -z "${workspace_root:-}" ]] && workspace_root="$(dirname "$(upsearch WORKSPACE)")"
[[ -d "${workspace_root:-}" ]] || exit_on_error "The workspace root was not found. ${workspace_root:-}"

parent_workspace_file="${workspace_root}/WORKSPACE"
all_workspace_files=( $(find "${workspace_root}" -name "WORKSPACE") )
child_workspace_files=()
for workspace_file in "${all_workspace_files[@]}" ; do
  [[ "${workspace_file}" != "${parent_workspace_file}" ]] && \
    child_workspace_files+=( "${workspace_file}" )
done

absolute_path_pkgs=()
for child_workspace_file in "${child_workspace_files[@]}" ; do
  child_workspace_dir="$(dirname "${child_workspace_file}")"
  absolute_path_pkgs+=( $(find_bazel_pkgs "${child_workspace_dir}") )
done
absolute_path_pkgs=( $(sort_items "${absolute_path_pkgs[@]}") )

# Strip the workspace_root prefix from the paths
pkgs=( "${absolute_path_pkgs[@]#"${workspace_root}/"}")

print_by_line "${pkgs[@]}"
