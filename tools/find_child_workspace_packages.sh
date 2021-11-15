#!/usr/bin/env bash

# This was lovingly inspired by
# https://github.com/bazelbuild/rules_python/blob/main/tools/bazel_integration_test/update_deleted_packages.sh.

# This utility will find all of the child workspace directories (i.e., contains
# WORKSPACE file) in a Bazel workspace. It is used in conjunction with
# update_deleted_packages.sh.

# --- begin runfiles.bash initialization v2 ---
# Copy-pasted from the Bazel Bash runfiles library v2.
set -uo pipefail; f=bazel_tools/tools/bash/runfiles/runfiles.bash
source "${RUNFILES_DIR:-/dev/null}/$f" 2>/dev/null || \
  source "$(grep -sm1 "^$f " "${RUNFILES_MANIFEST_FILE:-/dev/null}" | cut -f2- -d' ')" 2>/dev/null || \
  source "$0.runfiles/$f" 2>/dev/null || \
  source "$(grep -sm1 "^$f " "$0.runfiles_manifest" | cut -f2- -d' ')" 2>/dev/null || \
  source "$(grep -sm1 "^$f " "$0.exe.runfiles_manifest" | cut -f2- -d' ')" 2>/dev/null || \
  # Do not fail if this logic does not succeed. We are supporting being run 
  # outside of Bazel.
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

find_workspace_dirs() {
  local path="${1}"
  find "${path}" -name "WORKSPACE" | xargs -n 1 dirname
}

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

all_workspace_dirs=( $(find_workspace_dirs "${workspace_root}") )
child_workspace_dirs=()
for workspace_dir in "${all_workspace_dirs[@]}" ; do
  [[ "${workspace_dir}" != "${workspace_root}" ]] && \
    child_workspace_dirs+=( "${workspace_dir}" )
done

absolute_path_pkgs=()
for child_workspace_dir in "${child_workspace_dirs[@]}" ; do
  absolute_path_pkgs+=( $(find_bazel_pkgs "${child_workspace_dir}") )
done
absolute_path_pkgs=( $(sort_items "${absolute_path_pkgs[@]}") )

# Strip the workspace_root prefix from the paths
pkgs=( "${absolute_path_pkgs[@]#"${workspace_root}/"}")

print_by_line "${pkgs[@]}"
