#!/usr/bin/env bash

# This script performs an integration test for rules_bzlformat.
# Changes are made to a build file and a bzl file, then the update
# all command is run to format the changes and copy them back to 
# the workspace. Finally, the tests are run to be sure that everything
# is formatted.

set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" > /dev/null && pwd)"

backup_filename() {
  local filename="${1}"
  echo "${filename}.bak"
}

backup_file() {
  local filename="${1}"
  local backup_filename="$(backup_filename "${filename}")"
  cp -f "${filename}" "${backup_filename}"
}

revert_file() {
  local filename="${1}"
  local backup_filename="$(backup_filename "${filename}")"
  [[ -f "${backup_filename}" ]] && cp -f "${backup_filename}" "${filename}"
}

remove_backup_file() {
  local filename="${1}"
  local backup_filename="$(backup_filename "${filename}")"
  rm -f "${backup_filename}"
}

workspace_dir="${script_dir}"
foo_path="${workspace_dir}/mockascript/internal/foo.bzl"
internal_build_path="${workspace_dir}/mockascript/internal/BUILD.bazel"
mockascript_library_path="${workspace_dir}/mockascript/internal/mockascript_library.bzl"

modified_files=("${internal_build_path}" "${mockascript_library_path}")
for file in "${modified_files[@]}" ; do
  backup_file "${file}"
done


# Clean up on exit.
cleanup() {
  for file in "${modified_files[@]}" ; do
    revert_file "${file}"
    remove_backup_file "${file}"
  done
}
trap cleanup EXIT

# Change to workspace directory
cd "${workspace_dir}"

# Add poorly formatted code to build file.
echo "load(':foo.bzl', 'foo')" >> "${internal_build_path}"

# Add poorly formatted code to bzl file.
echo "load(':foo.bzl', 'foo'); foo(tags=['b', 'a'],srcs=['d', 'c'])" \
  >> "${mockascript_library_path}"

# Execute the update for the repository
bazel run //:update_all

# Make sure that all is well
bazel test //...


