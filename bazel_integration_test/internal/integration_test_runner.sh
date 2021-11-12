#!/usr/bin/env bash

set -euo pipefail

exit_on_error() {
  local err_msg="${1:-}"
  [[ -n "${err_msg}" ]] || err_msg="Unspecified error occurred."
  echo >&2 "${err_msg}"
  exit 1
}

normalize_path() {
  local path="${1}"
  echo "$(cd "${path}" > /dev/null && pwd)"
}

bazel_cmds=()

# Process args
while (("$#")); do
  case "${1}" in
    "--bazel")
      bazel_rel_path="${2}"
      shift 2
      ;;
    "--bazel_cmd")
      bazel_cmds+=("${2}")
      shift 2
      ;;
    "--workspace")
      workspace_path="${2}"
      shift 2
      ;;
    *)
      shift 1
      ;;
  esac
done

[[ -n "${bazel_rel_path:-}" ]] || exit_on_error "Must specify the location of the Bazel binary."
[[ -n "${workspace_path:-}" ]] || exit_on_error "Must specify the location of the workspace file."

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
