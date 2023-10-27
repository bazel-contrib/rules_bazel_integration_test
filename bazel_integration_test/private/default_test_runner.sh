#!/usr/bin/env bash

# This script is the default integration test runner. In addition to the 
# --bazel and --workspace flags, it also expects one or more --bazel_cmd
# flag-value pairs.

# NOTE: Do not introduce any external dependencies to this script!

exit_with_msg() {
  echo >&2 "${@}"
  exit 1
}

bazel_cmds=()
bazel="${BIT_BAZEL_BINARY:-}"
workspace_dir="${BIT_WORKSPACE_DIR:-}"

# Process args
while (("$#")); do
  case "${1}" in
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

for var_name in ${ENV_VARS_TO_ABSOLUTIFY:-}; do
  export "${var_name}=$(pwd)/$(printenv "${var_name}")"
done

cd "${workspace_dir}"

for cmd in "${bazel_cmds[@]}" ; do
  # Break the cmd string into parts
  read -a cmd_parts <<< ${cmd}
  # Execute the Bazel command
  "${bazel}" "${cmd_parts[@]}"
done
