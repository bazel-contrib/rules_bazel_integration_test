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
  { echo>&2 "ERROR: cannot find $f"; exit 1; }; f=; set -e
# --- end runfiles.bash initialization v2 ---

arrays_lib="$(rlocation cgrindel_bazel_starlib/shlib/lib/arrays.sh)"
source "${arrays_lib}"

files_lib="$(rlocation cgrindel_bazel_starlib/shlib/lib/files.sh)"
source "${files_lib}"

shared_fns_sh_location=contrib_rules_bazel_integration_test/tools/shared_fns.sh
shared_fns_sh="$(rlocation "${shared_fns_sh_location}")" || \
  (echo >&2 "Failed to locate ${shared_fns_sh_location}" && exit 1)
source "${shared_fns_sh}"

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

[[ -z "${workspace_root:-}" ]] && [[ -n "${BUILD_WORKING_DIRECTORY:-}"  ]] && workspace_root="${BUILD_WORKING_DIRECTORY:-}"
[[ -z "${workspace_root:-}" ]] && workspace_root="$(dirname "$(upsearch WORKSPACE)")"
[[ -d "${workspace_root:-}" ]] || exit_on_error "The workspace root was not found. ${workspace_root:-}"

all_workspace_dirs=()
while IFS=$'\n' read -r line; do all_workspace_dirs+=("$line"); done \
  < <(find_workspace_dirs "${workspace_root}")
[[ ${#all_workspace_dirs[@]} -gt 0 ]] || exit 0

child_workspace_dirs=()
for workspace_dir in "${all_workspace_dirs[@]}" ; do
  [[ "${workspace_dir}" != "${workspace_root}" ]] && \
    child_workspace_dirs+=( "${workspace_dir}" )
done

absolute_path_pkgs=()
for child_workspace_dir in "${child_workspace_dirs[@]}" ; do
  while IFS=$'\n' read -r line; do absolute_path_pkgs+=("$line"); done < <(
    find_bazel_pkgs "${child_workspace_dir}"
  )
done

# If no packages, then exit gracefully
[[ ${#absolute_path_pkgs[@]} -gt 0 ]] || exit 0
sorted_abs_path_pkgs=()
while IFS=$'\n' read -r line; do sorted_abs_path_pkgs+=("$line"); done < <(
  sort_items "${absolute_path_pkgs[@]}"
)

# Strip the workspace_root prefix from the paths
pkgs=( "${sorted_abs_path_pkgs[@]#"${workspace_root}/"}")

print_by_line "${pkgs[@]}"
