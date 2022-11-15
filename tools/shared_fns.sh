#!/usr/bin/env bash

find_workspace_dirs() {
  local path="${1}"
  find "${path}" -name "WORKSPACE" | xargs -n 1 dirname
}
