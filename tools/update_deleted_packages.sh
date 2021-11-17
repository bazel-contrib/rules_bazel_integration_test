#!/usr/bin/env bash

# This was lovingly inspired by
# https://github.com/bazelbuild/rules_python/blob/main/tools/bazel_integration_test/update_deleted_packages.sh.

# For integration tests, we want to be able to glob() up the sources for child workspaces. To do
# this and not have the parent workspace "see" the child workspaces, we specify the packages for the
# child worksapces as deleted packages in the parent workspace using the --deleted_packages flag.
#
# The .bazelrc for the parent workspace must contain the following lines:
#   build --deleted_packages=
#   query --deleted_packages=
# This utility will find the child workspaces and identify all of the Bazel packages under the child
# workspaces. It will then update the value for the --deleted_packages lines in the parent .bazelrc
# with a comma-separated list of the child workspace packages.

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

find_pkgs_script="$(rlocation cgrindel_rules_bazel_integration_test/tools/find_child_workspace_packages.sh)"

arrays_lib="$(rlocation cgrindel_bazel_shlib/lib/arrays.sh)"
source "${arrays_lib}"

files_lib="$(rlocation cgrindel_bazel_shlib/lib/files.sh)"
source "${files_lib}"

paths_lib="$(rlocation cgrindel_bazel_shlib/lib/paths.sh)"
source "${paths_lib}"

# MARK - Main

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
      shift 1 ;;
  esac
done

[[ -z "${workspace_root:-}" ]] && [[ ! -z "${BUILD_WORKING_DIRECTORY:-}"  ]] && workspace_root="${BUILD_WORKING_DIRECTORY:-}"
[[ -z "${workspace_root:-}" ]] && workspace_root="$(dirname "$(upsearch WORKSPACE)")"
[[ -d "${workspace_root:-}" ]] || exit_on_error "The workspace root was not found. ${workspace_root:-}"

[[ -z "${bazelrc_path:-}" ]] && bazelrc_path="${workspace_root}/.bazelrc"
[[ -f "${bazelrc_path:-}" ]] || exit_on_error "The bazelrc was not found. ${bazelrc_path:-}"

# Find the child packages
pkgs=( $(. "${find_pkgs_script}" --workspace "${workspace_root}") )

# Update the .bazelrc file with the deleted packages flag.
# The sed -i.bak pattern is compatible between macos and linux
sed -i.bak "/^[^#].*--deleted_packages/s#=.*#=$(\
    join_by , "${pkgs[@]}"\
)#" "${bazelrc_path}"
rm -f "${bazelrc_path}.bak"
