#!/usr/bin/env bash

# This script is used to call the test runner that is provided to the 
# bazel_integration_test.

# NOTE: Do not introduce any external dependencies to this script!

exit_with_msg() {
  echo >&2 "${@}"
  exit 1
}

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

# Export environment variables so that test runner does not need to parse args.
export BIT_BAZEL_BINARY="${bazel}"
export BIT_WORKSPACE_DIR="${workspace_dir_path}"

# Make sure that we have a TEST_TMPDIR.
if [[ -z "${TEST_TMPDIR:-}" ]]; then
  export TEST_TMPDIR="$(mktemp -d)" 
  cleanup() {
    rm -rf "${TEST_TMPDIR}"
  }
  trap cleanup EXIT
fi

# Execute the test runner
test_runner_cmd=( "${test_runner}" )
[[ ${#args[@]} > 0 ]] && test_runner_cmd+=( "${args[@]}" )
"${test_runner_cmd[@]}"
