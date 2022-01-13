#!/usr/bin/env bash

# This script is used to call the test runner that is provided to the 
# bazel_integration_test.

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

messages_sh_location=cgrindel_bazel_starlib/shlib/lib/messages.sh
messages_sh="$(rlocation "${messages_sh_location}")" || \
  (echo >&2 "Failed to locate ${messages_sh_location}" && exit 1)
source "${messages_sh}"

args=()
while (("$#")); do
  case "${1}" in
    "--bazel")
      bazel_rel_path="${2}"
      shift 2
      ;;
    "--workspace")
      workspace_file_path="${2}"
      shift 2
      ;;
    "--runner")
      test_runner_path="${2}"
      shift 2
      ;;
    *)
      args+=("${1}")
      shift 1
      ;;
  esac
done

[[ -n "${bazel_rel_path:-}" ]] || exit_with_msg "Must specify the location of the Bazel binary."
[[ -n "${test_runner_path:-}" ]] || exit_with_msg "Must specify a test runner."

# Be sure to pass absoulte paths to the test runner.
starting_path="${PWD%%*( )}"
bazel="${starting_path}/${bazel_rel_path}"
test_runner="${starting_path}/${test_runner_path}"

# Figure out the workspace directory path
if [[ -n "${workspace_file_path:-}" ]]; then
  full_workspace_path="${starting_path}/${workspace_file_path}"
  workspace_dir_path="$(dirname "${full_workspace_path}")"
else
  workspace_dir_path="${starting_path}/workspace"
  mkdir -p "${workspace_dir_path}"
fi

# Execute the test runner
test_runner_cmd=( "${test_runner}" --bazel "${bazel}" --workspace "${workspace_dir_path}" )
[[ ${#args[@]} > 0 ]] && test_runner_cmd+=( "${args[@]}" )
"${test_runner_cmd[@]}"
