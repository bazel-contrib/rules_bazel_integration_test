#!/usr/bin/env bash

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

# DEBUG BEGIN
echo >&2 "*** CHUCK integration_test_runner arguments" 
for (( i = 1; i <= ${#}; i++ )); do
  echo >&2 "*** CHUCK   ${i}: ${!i}"
done
# DEBUG END

bazel_cmds=()

# Process args
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
    "--bazel_cmd")
      bazel_cmds+=("${2}")
      shift 2
      ;;
    *)
      shift 1
      ;;
  esac
done

# DEBUG BEGIN
echo >&2 "*** CHUCK  bazel_rel_path: ${bazel_rel_path}" 
echo >&2 "*** CHUCK  workspace_path: ${workspace_path}" 
echo >&2 "*** CHUCK  bazel_cmds[@]:-: ${bazel_cmds[@]:-}" 
# DEBUG END

[[ -n "${bazel_rel_path:-}" ]] || exit_with_msg "Must specify the location of the Bazel binary."
[[ -n "${workspace_path:-}" ]] || exit_with_msg "Must specify the location of the workspace file."
[[ ${#bazel_cmds[@]} > 0 ]] || exit_with_msg "No Bazel commands were specified."

starting_path="$(pwd)"
starting_path="${starting_path%%*( )}"
bazel="${starting_path}/${bazel_rel_path}"

workspace_dir="$(dirname "${workspace_path}")"
cd "${workspace_dir}"

for cmd in "${bazel_cmds[@]}" ; do
  # Break the cmd string into parts
  read -a cmd_parts <<< ${cmd}
  # Execute the Bazel command
  "${bazel}" "${cmd_parts[@]}"
done
