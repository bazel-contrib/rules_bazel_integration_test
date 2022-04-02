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

assertions_lib="$(rlocation cgrindel_bazel_starlib/shlib/lib/assertions.sh)"
source "${assertions_lib}"

find_bin="$(rlocation contrib_rules_bazel_integration_test/tools/find_child_workspace_packages.sh)"

starting_path="${PWD}"

# Set up the parent workspace
setup_test_workspace_sh_location=contrib_rules_bazel_integration_test/tests/tools_tests/setup_test_workspace.sh
setup_test_workspace_sh="$(rlocation "${setup_test_workspace_sh_location}")" || \
  (echo >&2 "Failed to locate ${setup_test_workspace_sh_location}" && exit 1)
source "${setup_test_workspace_sh}"


expected=("examples/child_a" "examples/child_a/foo" "somewhere_else/child_b/bar")

# Execute specifying workspace flag
actual=( $(. "${find_bin}" --workspace "${parent_dir}") )
assert_equal "${#expected[@]}" "${#actual[@]}"
for (( i = 0; i < ${#expected[@]}; i++ )); do
  assert_equal "${expected[i]}" "${actual[i]}"
done


# Execute inside the parent workspace; find the parent workspace root
cd "${examples_dir}"
actual=( $(. "${find_bin}") )
assert_equal "${#expected[@]}" "${#actual[@]}"
for (( i = 0; i < ${#expected[@]}; i++ )); do
  assert_equal "${expected[i]}" "${actual[i]}"
done
