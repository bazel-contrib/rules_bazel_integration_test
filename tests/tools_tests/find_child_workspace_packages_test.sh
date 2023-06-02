#!/usr/bin/env bash

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

assertions_lib="$(rlocation cgrindel_bazel_starlib/shlib/lib/assertions.sh)"
# shellcheck disable=SC1090
source "${assertions_lib}"

find_bin="$(rlocation rules_bazel_integration_test/tools/find_child_workspace_packages.sh)"

initial_test_dir="${PWD}"

# MARK - Execute without a workspace

"${find_bin}" --workspace "${PWD}" \
  || fail "Expected no failure with no child workspace."

# MARK - Execute with empty workspace

empty_example_workspace_dir="${PWD}/examples/empty"
mkdir -p "${empty_example_workspace_dir}"
touch "${empty_example_workspace_dir}/WORKSPACE"

"${find_bin}" --workspace "${PWD}" \
  || fail "Expected no failure with empty child workspace."

rm -rf "${empty_example_workspace_dir}"

# MARK - Execute with a workspace

# Set up the parent workspace
setup_test_workspace_sh_location=rules_bazel_integration_test/tests/tools_tests/setup_test_workspace.sh
setup_test_workspace_sh="$(rlocation "${setup_test_workspace_sh_location}")" || \
  (echo >&2 "Failed to locate ${setup_test_workspace_sh_location}" && exit 1)
# shellcheck source=SCRIPTDIR/setup_test_workspace.sh
source "${setup_test_workspace_sh}"

expected=("examples/child_a" "examples/child_a/foo" "somewhere_else/child_b/bar")

# Execute specifying workspace flag
actual=()
while IFS=$'\n' read -r line; do actual+=("$line"); done < <(
  "${find_bin}" --workspace "${parent_dir}"
)
assert_equal "${#expected[@]}" "${#actual[@]}"
for (( i = 0; i < ${#expected[@]}; i++ )); do
  assert_equal "${expected[i]}" "${actual[i]}"
done

# Execute inside the parent workspace; find the parent workspace root
cd "${examples_dir}"

# Set the BUILD_WORKSPACE_DIRECTORY
export BUILD_WORKSPACE_DIRECTORY="${parent_dir}"

actual=()
while IFS=$'\n' read -r line; do actual+=("$line"); done < <(
  "${find_bin}"
)
assert_equal "${#expected[@]}" "${#actual[@]}"
for (( i = 0; i < ${#expected[@]}; i++ )); do
  assert_equal "${expected[i]}" "${actual[i]}"
done

# Unset the BUILD_WORKSPACE_DIRECTORY
unset BUILD_WORKSPACE_DIRECTORY

# Ensure that we ignore directories in .bazelignore

cd "${initial_test_dir}"
echo "somewhere_else" > "${parent_dir}/.bazelignore"
expected=("examples/child_a" "examples/child_a/foo")
actual=()
while IFS=$'\n' read -r line; do actual+=("$line"); done < <(
  "${find_bin}" --workspace "${parent_dir}"
)
assert_equal "${#expected[@]}" "${#actual[@]}"
for (( i = 0; i < ${#expected[@]}; i++ )); do
  assert_equal "${expected[i]}" "${actual[i]}"
done
