#!/usr/bin/env bash

# This was lovingly copied from
# https://github.com/bazelbuild/rules_python/blob/main/tools/bazel_integration_test/update_deleted_packages.sh.

# For integration tests, we want to be able to glob() up the sources inside a nested package
# See explanation in .bazelrc

set -euo pipefail

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

# Lovingly inspired by https://dev.to/meleu/how-to-join-array-elements-in-a-bash-script-303a
join_by() {
  local IFS="$1"
  shift
  echo "$*"
}

sort_items() {
  local IFS=$'\n'
  shift
  sort -u <<<"$*"
}

script_dir="$(normalize_path "${BASH_SOURCE[0]}")"
starting_dir=$(pwd)
pkg_search_dirs=()

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
    "--bazelrc")
      bazelrc_path="${2}"
      shift 2
      ;;
    *)
      pkg_search_dirs+=( "${1}" )
      shift 1
      ;;
  esac
done

# DEBUG BEGIN
set -x
# DEBUG END

[[ -z "${bazelrc_path:-}" ]] && bazelrc_path=$(upsearch .bazelrc)
[[ -f "${bazelrc_path:-}" ]] || exit_on_error "The bazelrc was not found. ${bazelrc_path:-}"

[[ -z "${workspace_root:-}" ]] && workspace_root="$(dirname "$(upsearch WORKSPACE)")"
[[ -d "${workspace_root:-}" ]] || exit_on_error "The workspace root was not found. ${workspace_root:-}"

[[ ${#pkg_search_dirs[@]} == 0 ]] && \
  examples_dir="${workspace_root}/examples" && \
  [[ -d "${examples_dir}" ]] && \
  pkg_search_dirs+=( "${examples_dir}" )

[[ ${#pkg_search_dirs[@]} -gt 0 ]] || exit_on_error "No search directories were specified."

pkgs=()
for search_dir in "${pkg_search_dirs[@]}" ; do
  pkgs+=( $(find_bazel_pkgs "${search_dir}") )
done

pkgs=( $(sort_items "${pkgs[@]}") )

# Update the .bazelrc file with the deleted packages flag.
# The sed -i.bak pattern is compatible between macos and linux
sed -i.bak "/^[^#].*--deleted_packages/s#=.*#=$(\
    join_by , "${pkgs[@]}"\
)#" "${bazelrc_path}"
rm -f "${bazelrc_path}.bak"

# cd "${workspace_root}"

# # Update the .bazelrc file with the deleted packages flag.
# # The sed -i.bak pattern is compatible between macos and linux
# sed -i.bak "/^[^#].*--deleted_packages/s#=.*#=$(\
#     find examples/*/* \( -name BUILD -or -name BUILD.bazel \) | xargs -n 1 dirname | paste -sd, -\
# )#" .bazelrc

# # Remove the the backup file.
# rm .bazelrc.bak

