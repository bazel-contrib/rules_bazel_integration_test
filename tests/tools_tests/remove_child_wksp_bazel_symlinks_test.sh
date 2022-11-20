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
  { echo>&2 "ERROR: cannot find $f"; exit 1; }; f=; set -o errexit
# --- end runfiles.bash initialization v2 ---

# MARK - Locate Deps

assertions_sh_location=cgrindel_bazel_starlib/shlib/lib/assertions.sh
assertions_sh="$(rlocation "${assertions_sh_location}")" || \
  (echo >&2 "Failed to locate ${assertions_sh_location}" && exit 1)
source "${assertions_sh}"

remove_child_wksp_bazel_symlinks_sh_location=contrib_rules_bazel_integration_test/tools/remove_child_wksp_bazel_symlinks.sh
remove_child_wksp_bazel_symlinks_sh="$(rlocation "${remove_child_wksp_bazel_symlinks_sh_location}")" || \
  (echo >&2 "Failed to locate ${remove_child_wksp_bazel_symlinks_sh_location}" && exit 1)

# Set up the parent workspace
setup_test_workspace_sh_location=contrib_rules_bazel_integration_test/tests/tools_tests/setup_test_workspace.sh
setup_test_workspace_sh="$(rlocation "${setup_test_workspace_sh_location}")" || \
  (echo >&2 "Failed to locate ${setup_test_workspace_sh_location}" && exit 1)
# shellcheck source=SCRIPTDIR/setup_test_workspace.sh
source "${setup_test_workspace_sh}"

# MARK - Test

bazel_out="${PWD}/bazel_out"
parent_bazel_out="${bazel_out}/parent"
child_a_bazel_out="${bazel_out}/child_a"
child_b_bazel_out="${bazel_out}/child_b"
mkdir -p "${bazel_out}" "${child_a_bazel_out}" "${child_b_bazel_out}" "${parent_bazel_out}"

# Add bazel symlinks
parent_symlink="${parent_dir}/bazel-parent"
child_a_symlink="${child_a_dir}/bazel-child_a"
child_b_symlink="${child_b_dir}/bazel-child_b"
ln -s "${parent_bazel_out}" "${parent_symlink}"
ln -s "${child_a_bazel_out}" "${child_a_symlink}"
ln -s "${child_b_bazel_out}" "${child_b_symlink}"

# Add a rogue symlink; looks like a bazel- symlink but is not in a workspace
# directory.
rogue_symlink="${examples_dir}/bazel-rogue"
ln -s "${bazel_out}" "${rogue_symlink}"

# Remove 
"${remove_child_wksp_bazel_symlinks_sh}" --workspace "${parent_dir}"

[[ -e "${parent_symlink}" ]] || fail "Expected parent symlink to exist. ${parent_symlink}"
[[ ! -e "${child_a_symlink}" ]] || fail "Expected child_a symlink not to exist. ${child_a_symlink}"
[[ ! -e "${child_b_symlink}" ]] || fail "Expected child_b symlink not to exist. ${child_b_symlink}"
[[ -e "${rogue_symlink}" ]] || fail "Expected rogue symlink to exist. ${rogue_symlink}"
