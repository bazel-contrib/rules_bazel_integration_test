#!/usr/bin/env bash

# This script is the default integration test runner. In addition to the 
# --bazel and --workspace flags, it also expects one or more --bazel_cmd
# flag-value pairs.

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

bazel_cmds=()

# Process args
while (("$#")); do
  case "${1}" in
    "--bazel")
      bazel="${2}"
      shift 2
      ;;
    "--workspace")
      workspace_dir="${2}"
      shift 2
      ;;
    "--bazel_cmd")
      bazel_cmds+=("${2}")
      shift 2
      ;;
    *)
      shift 1
      ;;
  esac
done


[[ -n "${bazel:-}" ]] || exit_with_msg "Must specify the location of the Bazel binary."
[[ -n "${workspace_dir:-}" ]] || exit_with_msg "Must specify the path of the workspace directory."
[[ ${#bazel_cmds[@]} > 0 ]] || exit_with_msg "No Bazel commands were specified."

cd "${workspace_dir}"

for cmd in "${bazel_cmds[@]}" ; do
  # Break the cmd string into parts
  read -a cmd_parts <<< ${cmd}
  # Execute the Bazel command
  "${bazel}" "${cmd_parts[@]}"
done
