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

assertions_lib="$(rlocation cgrindel_rules_bazel_integration_test/tools/assertions.sh)"
source "${assertions_lib}"

find_bin="$(rlocation cgrindel_rules_bazel_integration_test/tools/find_child_workspace_packages.sh)"

starting_path="${PWD}"

parent_dir="parent"
examples_dir="${parent_dir}/examples"
child_a_dir="${examples_dir}/child_a"
child_b_dir="${parent_dir}/somewhere_else/child_b"
child_a_pkg_dir="${child_a_dir}/foo"
child_b_pkg_dir="${child_b_dir}/bar"

directories=("${parent_dir}" "${examples_dir}" "${child_a_dir}" "${child_b_dir}")
directories+=("${child_a_pkg_dir}" "${child_b_pkg_dir}")
for dir in "${directories[@]}" ; do
  mkdir -p "${dir}"
done

parent_workspace="${parent_dir}/WORKSPACE"
child_a_workspace="${child_a_dir}/WORKSPACE"
child_b_workspace="${child_b_dir}/WORKSPACE"
workspaces=("${parent_workspace}" "${child_a_workspace}" "${child_b_workspace}")
for workspace in "${workspaces[@]}" ; do
  touch "${workspace}"
done

parent_build="${parent_dir}/BUILD.bazel"
examples_build="${examples_dir}/BUILD.bazel"
child_a_build="${child_a_dir}/BUILD"
child_a_pkg_build="${child_a_pkg_dir}/BUILD"
child_b_pkg_build="${child_b_pkg_dir}/BUILD.bazel"
build_files=("${parent_build}" "${examples_build}" "${child_a_build}" "${child_a_pkg_build}") 
build_files+=("${child_b_pkg_build}")
for build_file in "${build_files[@]}" ; do
  touch "${build_file}"
done

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
