#!/usr/bin/env bash

# --- begin runfiles.bash initialization v2 ---
# Copy-pasted from the Bazel Bash runfiles library v2.
set -o nounset -o pipefail; f=bazel_tools/tools/bash/runfiles/runfiles.bash
# shellcheck disable=SC1090
source "${RUNFILES_DIR:-/dev/null}/$f" 2>/dev/null || \
  source "$(grep -sm1 "^$f " "${RUNFILES_MANIFEST_FILE:-/dev/null}" | cut -f2- -d' ')" 2>/dev/null || \
  source "$0.runfiles/$f" 2>/dev/null || \
  source "$(grep -sm1 "^$f " "$0.runfiles_manifest" | cut -f2- -d' ')" 2>/dev/null || \
  source "$(grep -sm1 "^$f " "$0.exe.runfiles_manifest" | cut -f2- -d' ')" 2>/dev/null || \
  { echo>&2 "ERROR: ${BASH_SOURCE[0]} cannot find $f"; exit 1; }; f=; set -o errexit
# --- end runfiles.bash initialization v2 ---

# MARK - Locate Deps

assertions_sh_location=cgrindel_bazel_starlib/shlib/lib/assertions.sh
assertions_sh="$(rlocation "${assertions_sh_location}")" || \
  (echo >&2 "Failed to locate ${assertions_sh_location}" && exit 1)
source "${assertions_sh}"

shared_fns_sh_location=rules_bazel_integration_test/tools/shared_fns.sh
shared_fns_sh="$(rlocation "${shared_fns_sh_location}")" || \
  (echo >&2 "Failed to locate ${shared_fns_sh_location}" && exit 1)
source "${shared_fns_sh}"

# MARK - Test

foo_dir="foo"
bar_dir="${foo_dir}/bar"
rm -rf "${foo_dir}"
mkdir -p "${bar_dir}"
touch "${foo_dir}/HELLO"
touch "${foo_dir}/GOODBYE"
touch "${bar_dir}/HOWDY"
touch "${bar_dir}/LATER"

# Test no directory
( find_any_file 2>/dev/null && fail "Expected failure with missing directory." ) || true

# Test no filenames
( find_any_file "${foo_dir}" 2>/dev/null && fail "Expected failure with missing filenames." ) || true

test_msg="One filename"
output="$( find_any_file "${foo_dir}" HELLO | exec_cmd_for_each echo "{}" )"
assert_match "${foo_dir}/HELLO" "${output}" "${test_msg}"

test_msg="Two filenames, one does not exist"
output="$( find_any_file "${foo_dir}" HELLO DOES_NOT_EXIST | exec_cmd_for_each echo "{}" )"
assert_match "${foo_dir}/HELLO" "${output}" "${test_msg}"

test_msg="Two filenames, both exist"
output="$( find_any_file "${foo_dir}" HELLO HOWDY | exec_cmd_for_each echo "{}" )"
assert_match "${foo_dir}/HELLO" "${output}" "${test_msg}"
assert_match "${bar_dir}/HOWDY" "${output}" "${test_msg}"
