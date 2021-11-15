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

common_lib="$(rlocation cgrindel_rules_bazel_integration_test/tools/common.sh)"
source "${common_lib}"

starting_dir="${PWD}"

# Create a subdirectory
subdir="path/to/search/from"
mkdir -p "${subdir}"

# Create a file to find
target_file="file_to_find"
touch "${target_file}"

cd "${subdir}"

# Find a file
actual=$(upsearch "${target_file}")
assert_equal "$starting_dir/${target_file}" "${actual}"

# Do not find a file
actual=$(upsearch "file_does_not_exist")
assert_equal "" "${actual}"
