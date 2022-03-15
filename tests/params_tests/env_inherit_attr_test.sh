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

# MARK - Locate Deps

assertions_sh_location=cgrindel_bazel_starlib/shlib/lib/assertions.sh
assertions_sh="$(rlocation "${assertions_sh_location}")" || \
  (echo >&2 "Failed to locate ${assertions_sh_location}" && exit 1)
source "${assertions_sh}"

env_sh_location=cgrindel_bazel_starlib/shlib/lib/env.sh
env_sh="$(rlocation "${env_sh_location}")" || \
  (echo >&2 "Failed to locate ${env_sh_location}" && exit 1)
source "${env_sh}"

is_installed xmllint || fail "The env_inherit_attr_test requires xmllint to be installed."

# MARK - Process Args

query_output="${1}"
shift 1

expected_env_inherit_values=()
while (("$#")); do
  expected_env_inherit_values+=( "${1}" )
  shift 1
done

[[ ${#expected_env_inherit_values} == 0 ]] && fail "No expected values were provided."


# MARK - Assertion Functions

assert_env_inherit_value() {
  local attr="${1}"
  local xpath='//rule[@class="sh_test"]/list[@name="env_inherit"]/string[@value="'"${attr}"'"]'
  if xmllint --xpath "${xpath}" "${query_output}" &>/dev/null; then 
    return 0
  else
    fail "Did not find env_inherit value. expected: ${attr}"
  fi
}

# MARK - Test

for value in "${expected_env_inherit_values[@]}" ; do
  assert_env_inherit_value "${value}"
done
