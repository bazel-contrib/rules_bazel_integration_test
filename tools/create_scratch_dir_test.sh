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

assertions_lib="$(rlocation cgrindel_bazel_shlib/lib/assertions.sh)"
source "${assertions_lib}"

create_scratch_dir_sh_location=cgrindel_rules_bazel_integration_test/tools/create_scratch_dir.sh
create_scratch_dir_sh="$(rlocation "${create_scratch_dir_sh_location}")" || \
  (echo >&2 "Failed to locate ${create_scratch_dir_sh_location}" && exit 1)

# MARK - Create a workspace directory

starting_dir="${PWD}"

# Create a source file that will be symlinked
foo_path="${PWD}/foo"
bar_path="${PWD}/.bar"
echo "Foo File" > "${foo_path}"
echo "Bar File" > "${bar_path}"

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

cd "${workspace_dir}"
scratch_dir="$("${create_scratch_dir_sh}")"

assert_equal "${starting_dir}/workspace.scratch" "${scratch_dir}"

fail "IMPLEMENT ME!"
