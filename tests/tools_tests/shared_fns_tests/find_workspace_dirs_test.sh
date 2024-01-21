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

shared_fns_sh_location=rules_bazel_integration_test/tools/shared_fns.sh
shared_fns_sh="$(rlocation "${shared_fns_sh_location}")" || \
  (echo >&2 "Failed to locate ${shared_fns_sh_location}" && exit 1)
source "${shared_fns_sh}"

# MARK - Setup

root_dir="root"
just_repo_bazel_dir="${root_dir}/just_repo_bazel_dir"
just_module_bazel_dir="${root_dir}/just_module_bazel_dir"
just_workspace_bazel_dir="${root_dir}/just_workspace_bazel_dir"
just_workspace_dir="${root_dir}/just_workspace_dir"
combined_dir="${root_dir}/combined"
rm -rf "${root_dir}"
mkdir -p \
  "${just_repo_bazel_dir}" \
  "${just_module_bazel_dir}" \
  "${just_workspace_bazel_dir}" \
  "${just_workspace_dir}" \
  "${combined_dir}"
touch \
  "${just_repo_bazel_dir}/REPO.bazel" \
  "${just_module_bazel_dir}/MODULE.bazel" \
  "${just_workspace_bazel_dir}/WORKSPACE.bazel" \
  "${just_workspace_dir}/WORKSPACE" \
  "${combined_dir}/REPO.bazel" \
  "${combined_dir}/MODULE.bazel" \
  "${combined_dir}/WORKSPACE"

# MARK - Test

expected=( \
  "${combined_dir}" \
  "${just_module_bazel_dir}" \
  "${just_repo_bazel_dir}" \
  "${just_workspace_bazel_dir}" \
  "${just_workspace_dir}" \
)

actual=()
while IFS=$'\n' read -r line; do actual+=("$line"); done < <(
  find_workspace_dirs "${root_dir}" 
)
assert_equal "${#expected[@]}" "${#actual[@]}"
for (( i = 0; i < ${#expected[@]}; i++ )); do
  assert_equal "${expected[i]}" "${actual[i]}"
done
