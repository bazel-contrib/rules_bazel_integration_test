#!/usr/bin/env bash

# --- begin runfiles.bash initialization v2 ---
# Copy-pasted from the Bazel Bash runfiles library v2.
set -o nounset -o pipefail; f=bazel_tools/tools/bash/runfiles/runfiles.bash
source "${RUNFILES_DIR:-/dev/null}/$f" 2>/dev/null || \
  source "$(grep -sm1 "^$f " "${RUNFILES_MANIFEST_FILE:-/dev/null}" | cut -f2- -d' ')" 2>/dev/null || \
  source "$0.runfiles/$f" 2>/dev/null || \
  source "$(grep -sm1 "^$f " "$0.runfiles_manifest" | cut -f2- -d' ')" 2>/dev/null || \
  source "$(grep -sm1 "^$f " "$0.exe.runfiles_manifest" | cut -f2- -d' ')" 2>/dev/null || \
  { echo>&2 "ERROR: cannot find $f"; exit 1; }; f=; set -o errexit
# --- end runfiles.bash initialization v2 ---

# MARK - Locate Deps

fail_sh_location=cgrindel_bazel_starlib/shlib/lib/fail.sh
fail_sh="$(rlocation "${fail_sh_location}")" || \
  (echo >&2 "Failed to locate ${fail_sh_location}" && exit 1)
source "${fail_sh}"

shared_fns_sh_location=contrib_rules_bazel_integration_test/tools/shared_fns.sh
shared_fns_sh="$(rlocation "${shared_fns_sh_location}")" || \
  (echo >&2 "Failed to locate ${shared_fns_sh_location}" && exit 1)
source "${shared_fns_sh}"

# MARK - Functions

remove_bazel_symlinks() {
  local workspace_dir="${1}"
  find "${workspace_dir}" -maxdepth 1 -type l -name "bazel-*" -print0 | xargs -0 rm
}

# MARK - Process Args

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
[[ -d "${workspace_root:-}" ]] || fail "The workspace root was not found. ${workspace_root:-}"

workspace_dirs=()
while IFS=$'\n' read -r line; do workspace_dirs+=("$line"); done < <(
  find_workspace_dirs "${workspace_root}"
)

[[ ${#workspace_dirs[@]} -gt 0 ]] || (warn "No workspace directories were found."; exit 0)

for workspace_dir in "${workspace_dirs[@]}" ; do
  if [[ "${workspace_dir}" == "${workspace_root}" ]]; then
    continue
  fi
  remove_bazel_symlinks "${workspace_dir}"
done
