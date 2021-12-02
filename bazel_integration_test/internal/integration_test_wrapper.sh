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

messages_sh_location=cgrindel_bazel_shlib/lib/messages.sh
messages_sh="$(rlocation "${messages_sh_location}")" || \
  (echo >&2 "Failed to locate ${messages_sh_location}" && exit 1)
source "${messages_sh}"

paths_sh_location=cgrindel_bazel_shlib/lib/paths.sh
paths_sh="$(rlocation "${paths_sh_location}")" || \
  (echo >&2 "Failed to locate ${paths_sh_location}" && exit 1)
source "${paths_sh}"

args=()
while (("$#")); do
  case "${1}" in
    "--bazel")
      bazel_rel_path="${2}"
      shift 2
      ;;
    "--workspace")
      workspace_path="${2}"
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
[[ -n "${workspace_path:-}" ]] || exit_with_msg "Must specify the location of the workspace file."
[[ -n "${test_runner_path:-}" ]] || exit_with_msg "Must specify a test runner."

# DEBUG BEGIN
echo >&2 "*** CHUCK WRAPPER" 
echo >&2 "*** CHUCK  PWD: ${PWD}" 
echo >&2 "*** CHUCK bazel_rel_path: ${bazel_rel_path}" 
ls -l "${bazel_rel_path}"
# DEBUG END

starting_path="${PWD%%*( )}"
# bazel="$(normalize_path "${starting_path}/${bazel_rel_path}")"
# workspace="$(normalize_path "${starting_path}/${workspace_path}")"
# test_runner="$(normalize_path "${starting_path}/${test_runner_path}")"
bazel="${starting_path}/${bazel_rel_path}"
workspace="${starting_path}/${workspace_path}"
test_runner="${starting_path}/${test_runner_path}"

# DEBUG BEGIN
echo >&2 "*** CHUCK WRAPPER RESOLVED" 
echo >&2 "*** CHUCK  bazel: ${bazel}" 
ls -l "${bazel}"
set -x
# DEBUG END

if [[ ${#args[@]} > 0 ]]; then
  "${test_runner}" --bazel "${bazel}" --workspace "${workspace}" "${args[@]:-}"
else
  "${test_runner}" --bazel "${bazel}" --workspace "${workspace}"
fi

