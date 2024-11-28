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

assertions_sh_location=cgrindel_bazel_starlib/shlib/lib/assertions.sh
assertions_sh="$(rlocation "${assertions_sh_location}")" || \
  (echo >&2 "Failed to locate ${assertions_sh_location}" && exit 1)
source "${assertions_sh}"

arrays_sh_location=cgrindel_bazel_starlib/shlib/lib/arrays.sh
arrays_sh="$(rlocation "${arrays_sh_location}")" || \
  (echo >&2 "Failed to locate ${arrays_sh_location}" && exit 1)
source "${arrays_sh}"

create_scratch_dir_sh_location=rules_bazel_integration_test/tools/create_scratch_dir.sh
create_scratch_dir_sh="$(rlocation "${create_scratch_dir_sh_location}")" || \
  (echo >&2 "Failed to locate ${create_scratch_dir_sh_location}" && exit 1)


# MARK - Process Flags

bazel="${BIT_BAZEL_BINARY:-}"
workspace_dir="${BIT_WORKSPACE_DIR:-}"

# Process args
while (("$#")); do
  case "${1}" in
    *)
      shift 1
      ;;
  esac
done

[[ -n "${bazel:-}" ]] || fail "Must specify the location of the Bazel binary."
[[ -n "${workspace_dir:-}" ]] || fail "Must specify the path of the workspace directory."

# MARK - Create Scratch Directory

scratch_dir="$("${create_scratch_dir_sh}" --workspace "${workspace_dir}")"
cd "${scratch_dir}"

# MARK - Make sure the workspace builds in the scratch directory

# Should not fail
"${bazel}" test //... || fail "Expected tests to succeed in the scratch directory."

expected_hidden_files=( ./.bazelrc ./.hidden_file ./mockascript/private/.another_hidden_file )
found_hidden_files=()
while IFS=$'\n' read -r line; do found_hidden_files+=("$line"); done < <(
  find . -type f -name ".*"
)
assert_equal "${#expected_hidden_files[@]}" "${#found_hidden_files[@]}" "expected count"

sorted=()
while IFS=$'\n' read -r line; do sorted+=("$line"); done < <(
  sort_items "${found_hidden_files[@]}"
)
for (( i = 0; i < "${#expected_hidden_files[@]}"; i++ )); do
  assert_equal "${expected_hidden_files[i]}" "${sorted[i]}" "hidden file ${i} ${expected_hidden_files[i]}"
done
