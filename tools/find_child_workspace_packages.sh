#!/usr/bin/env bash

# This was lovingly inspired by
# https://github.com/bazelbuild/rules_python/blob/main/tools/bazel_integration_test/update_deleted_packages.sh.

# For integration tests, we want to be able to glob() up the sources inside a nested package
# See explanation in .bazelrc

# set -euo pipefail

# --- begin runfiles.bash initialization v2 ---
# Copy-pasted from the Bazel Bash runfiles library v2.
set -uo pipefail; f=bazel_tools/tools/bash/runfiles/runfiles.bash
source "${RUNFILES_DIR:-/dev/null}/$f" 2>/dev/null || \
  source "$(grep -sm1 "^$f " "${RUNFILES_MANIFEST_FILE:-/dev/null}" | cut -f2- -d' ')" 2>/dev/null || \
  source "$0.runfiles/$f" 2>/dev/null || \
  source "$(grep -sm1 "^$f " "$0.runfiles_manifest" | cut -f2- -d' ')" 2>/dev/null || \
  source "$(grep -sm1 "^$f " "$0.exe.runfiles_manifest" | cut -f2- -d' ')" 2>/dev/null || \
  # { echo>&2 "ERROR: cannot find $f"; exit 1; }; f=; set -e
  f=; set -e
# --- end runfiles.bash initialization v2 ---

# Do not use helper functions as they have not been loaded yet
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" > /dev/null && pwd)"

# If we are being run via `bazel run` the rlocation function will exist and we
# will load the common functions using rlocation. Otherwise, we are being executed
# directly.
if [[ $(type -t rlocation) == function ]]; then
  common_lib="$(rlocation cgrindel_rules_bazel_integration_test/tools/common.sh)"
else
  common_lib="${script_dir}/common.sh"
fi
source "${common_lib}"

# MARK - Functions

find_bazel_pkgs() {
  local path="${1}"
  find "${path}" \( -name BUILD -or -name BUILD.bazel \) | xargs -n 1 dirname 
}

# MARK - Main

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
