#!/usr/bin/env bash

find_workspace_dirs() {
  local path="${1}"
  # Make sure that the -print0 is the last primary for find. Otherwise, you
  # will get undesirable results.
  find "${path}" -name "WORKSPACE" -o -name "WORKSPACE.bazel" -print0  | xargs -0 -n 1 dirname
}
