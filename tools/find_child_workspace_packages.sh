#!/usr/bin/env bash

# This was lovingly inspired by
# https://github.com/bazelbuild/rules_python/blob/main/tools/bazel_integration_test/update_deleted_packages.sh.

# This utility will find all of the child workspace directories (i.e., contains
# WORKSPACE file) in a Bazel workspace. It is used in conjunction with
# update_deleted_packages.sh.

# --- begin runfiles.bash initialization v2 ---
# Copy-pasted from the Bazel Bash runfiles library v2.
set -uo pipefail; f=bazel_tools/tools/bash/runfiles/runfiles.bash
# shellcheck disable=SC1090
source "${RUNFILES_DIR:-/dev/null}/$f" 2>/dev/null || \
  source "$(grep -sm1 "^$f " "${RUNFILES_MANIFEST_FILE:-/dev/null}" | cut -f2- -d' ')" 2>/dev/null || \
  source "$0.runfiles/$f" 2>/dev/null || \
  source "$(grep -sm1 "^$f " "$0.runfiles_manifest" | cut -f2- -d' ')" 2>/dev/null || \
  source "$(grep -sm1 "^$f " "$0.exe.runfiles_manifest" | cut -f2- -d' ')" 2>/dev/null || \
  { echo>&2 "ERROR: cannot find $f"; exit 1; }; f=; set -e
# --- end runfiles.bash initialization v2 ---

arrays_lib="$(rlocation cgrindel_bazel_starlib/shlib/lib/arrays.sh)"
# shellcheck disable=SC1090
source "${arrays_lib}"

files_lib="$(rlocation cgrindel_bazel_starlib/shlib/lib/files.sh)"
# shellcheck disable=SC1090
source "${files_lib}"

fail_sh_location=cgrindel_bazel_starlib/shlib/lib/fail.sh
fail_sh="$(rlocation "${fail_sh_location}")" || \
  (echo >&2 "Failed to locate ${fail_sh_location}" && exit 1)
# shellcheck disable=SC1090
source "${fail_sh}"

shared_fns_sh_location=rules_bazel_integration_test/tools/shared_fns.sh
shared_fns_sh="$(rlocation "${shared_fns_sh_location}")" || \
  (echo >&2 "Failed to locate ${shared_fns_sh_location}" && exit 1)
# shellcheck source=SCRIPTDIR/shared_fns.sh
source "${shared_fns_sh}"

# MARK - Functions

find_bazel_pkgs() {
  local path="${1}"

  # Make sure that the -print0 is the last primary for find. Otherwise, you
  # will get undesirable results.
  while IFS=$'\n' read -r line; do filter_bazelignored_directories "${path}" "${line}" ; done < <(
    # NOTE: If you update the find or xargs flags, be sure to check if those 
    # changes should be applied to find_workspace_dirs in shared_fns.sh.
    # The -r in the xargs tells gnu xargs not to run if empty. The FreeBSD 
    # version supports the flag, but ignores it as it provides this behavior
    # by default.
    # The -S 511 addresses "xargs: command line cannot be assembled, too long" 
    # errors that can occur if the found paths are long.
    find "${path}" \( -name BUILD -or -name BUILD.bazel \) -print0 | \
      xargs -r -0 -S 511 -I {} dirname "{}"
  )
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

if [[ -z "${workspace_root:-}" ]]; then
  workspace_root="${BUILD_WORKSPACE_DIRECTORY:-}"
fi
if [[ ! -d "${workspace_root:-}" ]]; then
  fail "The workspace root was not found. ${workspace_root:-}"
fi

all_workspace_dirs=()
while IFS=$'\n' read -r line; do all_workspace_dirs+=("$line"); done < <(
  find_workspace_dirs "${workspace_root}"
)
if [[ ${#all_workspace_dirs[@]} -eq 0 ]]; then
  exit 0
fi

child_workspace_dirs=()
for workspace_dir in "${all_workspace_dirs[@]}" ; do
  if [[ "${workspace_dir}" != "${workspace_root}" ]]; then
    child_workspace_dirs+=( "${workspace_dir}" )
  fi
done
if [[ ${#child_workspace_dirs[@]} -eq 0 ]]; then
  exit 0
fi

absolute_path_pkgs=()
for child_workspace_dir in "${child_workspace_dirs[@]}" ; do
  while IFS=$'\n' read -r line; do absolute_path_pkgs+=("$line"); done < <(
    find_bazel_pkgs "${child_workspace_dir}" 
  )
done
if [[ ${#absolute_path_pkgs[@]} -eq 0 ]]; then
  exit 0
fi

sorted_abs_path_pkgs=()
while IFS=$'\n' read -r line; do sorted_abs_path_pkgs+=("$line"); done < <(
  sort_items "${absolute_path_pkgs[@]}"
)

# Strip the workspace_root prefix from the paths
pkgs=( "${sorted_abs_path_pkgs[@]#"${workspace_root}/"}")

print_by_line "${pkgs[@]}"
