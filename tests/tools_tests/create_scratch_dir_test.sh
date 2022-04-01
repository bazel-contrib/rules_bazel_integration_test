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

create_scratch_dir_sh_location=bazel_contrib_rules_bazel_integration_test/tools/create_scratch_dir.sh
create_scratch_dir_sh="$(rlocation "${create_scratch_dir_sh_location}")" || \
  (echo >&2 "Failed to locate ${create_scratch_dir_sh_location}" && exit 1)

# MARK - Functions

assert_file() {
  local assert_prefix="${1}"
  local expected_path="${2}"
  local expected_content="${3}"
  [[ -f "${expected_path}" ]] || fail "${assert_prefix} Expected ${expected_path} file to exist."
  actual_content="$(< "${expected_path}")"
  assert_equal "${expected_content}" "${actual_content}" "${assert_prefix} Expected ${expected_path} content not found."
}

# MARK - Create a workspace directory

starting_dir="${PWD}"

# Create a source file that will be symlinked
foo_path="${PWD}/foo"
bar_path="${PWD}/.bar"
echo "Foo File" > "${foo_path}"
echo "Bar File" > "${bar_path}"
foo_content="$(< "${foo_path}")"
bar_content="$(< "${bar_path}")"

# Create the workspace directory
workspace_dir="${PWD}/workspace"
workspace_chicken_dir="${workspace_dir}/chicken"
mkdir -p "${workspace_chicken_dir}"

# Create symlinks
foo_workspace_path="${workspace_chicken_dir}/foo"
bar_workspace_path="${workspace_chicken_dir}/.bar"
ln -s "${foo_path}" "${foo_workspace_path}"
ln -s "${bar_path}" "${bar_workspace_path}"

# MARK - Create the scratch dir from workspace dir

assert_prefix="Create scratch from workspace dir."
expected_scratch_dir="${starting_dir}/workspace.scratch"
expected_foo_scratch_path="${expected_scratch_dir}/chicken/foo"
expected_bar_scratch_path="${expected_scratch_dir}/chicken/.bar"


# Add content to to expected scratch dir to confirm that it is removed.
mkdir -p "${expected_scratch_dir}"
should_not_exist_path="${expected_scratch_dir}/SHOULD_NOT_EXIST"
echo "SHOULD NOT EXIST" > "${should_not_exist_path}"

cd "${workspace_dir}"
scratch_dir="$("${create_scratch_dir_sh}")"
assert_equal "${workspace_dir}" "${PWD}"
assert_file "${assert_prefix}" "${expected_foo_scratch_path}" "${foo_content}"
assert_file "${assert_prefix}" "${expected_bar_scratch_path}" "${bar_content}"
[[ ! -f "${should_not_exist_path}" ]] || fail "Pre-existing content was not removed."

# Remove the scratch dir
rm -rf "${expected_scratch_dir}"

# MARK - Create the scratch dir using workspace flag

assert_prefix="Create scratch using workspace flag."
expected_scratch_dir="${starting_dir}/workspace.scratch"
expected_foo_scratch_path="${expected_scratch_dir}/chicken/foo"
expected_bar_scratch_path="${expected_scratch_dir}/chicken/.bar"

cd "${starting_dir}"
scratch_dir="$("${create_scratch_dir_sh}" --workspace "${workspace_dir}")"
assert_equal "${starting_dir}" "${PWD}" "${assert_prefix}"
assert_file "${assert_prefix}" "${expected_foo_scratch_path}" "${foo_content}"
assert_file "${assert_prefix}" "${expected_bar_scratch_path}" "${bar_content}"

rm -rf "${expected_scratch_dir}"

# MARK - Create the scratch dir using workspace flag and scratch flag

assert_prefix="Create scratch using workspace flag."
expected_scratch_dir="${starting_dir}/custom_scratch"
expected_foo_scratch_path="${expected_scratch_dir}/chicken/foo"
expected_bar_scratch_path="${expected_scratch_dir}/chicken/.bar"

cd "${starting_dir}"
scratch_dir="$("${create_scratch_dir_sh}" --workspace "${workspace_dir}" --scratch "${expected_scratch_dir}")"
assert_equal "${starting_dir}" "${PWD}" "${assert_prefix}"
assert_file "${assert_prefix}" "${expected_foo_scratch_path}" "${foo_content}"
assert_file "${assert_prefix}" "${expected_bar_scratch_path}" "${bar_content}"

rm -rf "${expected_scratch_dir}"
