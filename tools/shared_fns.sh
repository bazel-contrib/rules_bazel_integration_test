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

is_macos() {
  local os_name
  os_name="$( uname )"
  [[ "${os_name}" == "Darwin" ]]
}

exec_cmd_for_each() {
  # The -r in the xargs tells gnu xargs not to run if empty. The FreeBSD 
  # version supports the flag, but ignores it as it provides this behavior
  # by default.
  local cmd=( xargs -r -0 -I {} )
  if is_macos; then
    # FreeBSD version of xargs limits the command length to 255 characters. 
    # Long paths can exceed that length. The -S 511 addresses "xargs: command 
    # line cannot be assembled, too long" errors that can occur if the found 
    # paths are long.
    cmd+=( -S 511 )
  fi
  "${cmd[@]}" "$@"
}

find_any_file() {
  local dir="${1}"
  if [[ -z "${dir:-}" ]]; then
    echo >&2 "No directory was provided."
    return 1
  fi
  shift 1
  local arg_cnt=${#}
  if [[ ${arg_cnt} -eq 0 ]]; then
    echo >&2 "No file names provided to find_any_file."
    return 1
  fi
  local last_idx=$(( arg_cnt - 1 ))
  local find_cmd=( find "${dir}" \( )
  local idx=0
  for fname in "${@}" ; do
    find_cmd+=( -name "${fname}" )
    if [[ ${idx} -ne ${last_idx} ]]; then
      find_cmd+=( -o )
    fi
    idx=$(( idx + 1 ))
  done
  find_cmd+=( \) -print0 )
  "${find_cmd[@]}"
}

find_workspace_dirs() {
  local path="${1}"
  # Make sure that the -print0 is the last primary for find. Otherwise, you
  # will get undesirable results.
  while IFS=$'\n' read -r line; do filter_bazelignored_directories "${path}" "${line}" ; done < <(
    # NOTE: If you update the find or xargs flags, be sure to check if those 
    # changes should be applied to find_bazel_pkgs in find_child_workspace_packages.sh.
    # find "${path}" \( -name "WORKSPACE" -o -name "WORKSPACE.bazel" \) -print0  | \
    find_any_file "${path}" "WORKSPACE" "WORKSPACE.bazel" | \
      exec_cmd_for_each dirname "{}"
  )
}
