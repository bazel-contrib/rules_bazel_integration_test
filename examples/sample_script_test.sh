#!/bin/bash

# A sample test script which wants to execute Bazel commands and check the
# result with assertions. script tests are responsible for creating the needed
# files in the workspace and calling `${bazel}` as needed.

# --- begin runfiles.bash initialization v2 ---
# Copy-pasted from the Bazel Bash runfiles library v2.
set -uo pipefail; f=bazel_tools/tools/bash/runfiles/runfiles.bash
source "${RUNFILES_DIR:-/dev/null}/$f" 2>/dev/null || \
  source "$(grep -sm1 "^$f " "${RUNFILES_MANIFEST_FILE:-/dev/null}" | cut -f2- -d' ')" 2>/dev/null || \
  source "$0.runfiles/$f" 2>/dev/null || \
  source "$(grep -sm1 "^$f " "$0.runfiles_manifest" | cut -f2- -d' ')" 2>/dev/null || \
  source "$(grep -sm1 "^$f " "$0.exe.runfiles_manifest" | cut -f2- -d' ')" 2>/dev/null || \
  { echo>&2 "ERROR: ${BASH_SOURCE[0]} cannot find $f"; exit 1; }; f=; set -e
# --- end runfiles.bash initialization v2 ---

# Use shlib assertions for testing.
assertions_sh_location=cgrindel_bazel_starlib/shlib/lib/assertions.sh
assertions_sh="$(rlocation "${assertions_sh_location}")" || \
  (echo >&2 "Failed to locate ${assertions_sh_location}" && exit 1)
# shellcheck disable=SC1090 # external source
source "${assertions_sh}"

logfile="${TEST_TMPDIR}/test.log"

# Verify the Bazel binary by checking the release number.
touch WORKSPACE
${BIT_BAZEL_BINARY} info release > "${logfile}"

if ! grep -E -q "^release [0-9]+\.[0-9]+\.[0-9]" "${logfile}"; then
  fail "Did not find release in output of '$(cat "${logfile}")'"
fi
