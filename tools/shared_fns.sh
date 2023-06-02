#!/usr/bin/env bash

filter_bazelignored_directories() {
  local workspace_root="${1}"
  local path="${2}"

  # If the path and the workspace_root are equal, then there is nothing to 
  # check.
  if [[ "${workspace_root}" == "${path}" ]]; then
    echo "${path}"
    return
  fi

  if [[ -f "${workspace_root}/.bazelignore" ]]; then
    local path_relative_to_workspace="${path#"${workspace_root}"/}"
    local bazelignore_dirs=()
    while IFS=$'\n' read -r line; do bazelignore_dirs+=("$line"); done < <(
      grep -v '^#' "${workspace_root}/.bazelignore" | grep "."
    )
    if [[ ${#bazelignore_dirs[@]} -eq 0 ]]; then
      echo "${path}"
      return
    fi
    for bazelignore_dir in "${bazelignore_dirs[@]}"; do
      if [[ "${path_relative_to_workspace}" == "${bazelignore_dir}" || "${path_relative_to_workspace}" == "${bazelignore_dir}/"* ]]; then
        return
      fi
    done
  fi

  echo "${path}"
}

find_workspace_dirs() {
  local path="${1}"
  # Make sure that the -print0 is the last primary for find. Otherwise, you
  # will get undesirable results.
  while IFS=$'\n' read -r line; do filter_bazelignored_directories "${path}" "${line}" ; done < <(
    find "${path}" \( -name "WORKSPACE" -o -name "WORKSPACE.bazel" \) -print0  | xargs -0 -n 1 dirname
  )
}
