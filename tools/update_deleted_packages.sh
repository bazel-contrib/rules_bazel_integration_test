#!/usr/bin/env bash

# This was lovingly inspired by
# https://github.com/bazelbuild/rules_python/blob/main/tools/bazel_integration_test/update_deleted_packages.sh.

# For integration tests, we want to be able to glob() up the sources inside a nested package
# See explanation in .bazelrc

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
  find_pkgs_script="$(rlocation cgrindel_rules_bazel_integration_test/tools/find_child_workspace_packages.sh)"
else
  common_lib="${script_dir}/common.sh"
  find_pkgs_script="${script_dir}/find_child_workspace_packages.sh"
fi
source "${common_lib}"

# MARK - Functions

# Lovingly inspired by https://dev.to/meleu/how-to-join-array-elements-in-a-bash-script-303a
join_by() {
  local IFS="$1"
  shift
  echo "$*"
}

# MARK - Main

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
