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

rules_bazel_integration_test_tar_gz_location=rules_bazel_integration_test/release/rules_bazel_integration_test.tar.gz
rules_bazel_integration_test_tar_gz="$(rlocation "${rules_bazel_integration_test_tar_gz_location}")" || \
  (echo >&2 "Failed to locate ${rules_bazel_integration_test_tar_gz_location}" && exit 1)

# MARK - Process Args

bazel="${BIT_BAZEL_BINARY:-}"
workspace_dir="${BIT_WORKSPACE_DIR:-}"

# Process args
while (("$#")); do
  case "${1}" in
    *)
      fail "Unrecognized argument. ${@}"
      ;;
  esac
done

[[ -n "${bazel:-}" ]] || exit_with_msg "Must specify the location of the Bazel binary."
[[ -n "${workspace_dir:-}" ]] || exit_with_msg "Must specify the path of the workspace directory."

# MARK - Create a HOME directory

# Not sure why, but the download and extract for the Bazel binaries was
# experiencing a permission denied when trying to use the local repository
# cache.
home_dir="${PWD}/home"
mkdir -p "${home_dir}"
export HOME="${home_dir}"

# MARK - Create a WORKSPACE

# Extract the contents of the archive into the workspace directory
tar -xf "${rules_bazel_integration_test_tar_gz}" -C "${workspace_dir}"

# Test the extracted contents
cd "${workspace_dir}"
"${bazel}" test //bazel_integration_test/bzlmod/...
