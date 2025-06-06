#!/usr/bin/env bash

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


# MARK - Source Libraries

fail_sh_location=cgrindel_bazel_starlib/shlib/lib/fail.sh
fail_sh="$(rlocation "${fail_sh_location}")" || \
  (echo >&2 "Failed to locate ${fail_sh_location}" && exit 1)
source "${fail_sh}"

paths_sh_location=cgrindel_bazel_starlib/shlib/lib/paths.sh
paths_sh="$(rlocation "${paths_sh_location}")" || \
  (echo >&2 "Failed to locate ${paths_sh_location}" && exit 1)
source "${paths_sh}"

# MARK - Process Arguments

args=()
while (("$#")); do
  case "${1}" in
    "--workspace")
      workspace_dir="${2}"
      shift 2
      ;;
    "--scratch")
      scratch_dir="${2}"
      shift 2
      ;;
    *)
      shift 1
      ;;
  esac
done

[[ -z "${workspace_dir:-}" ]] && workspace_dir="${PWD}"
[[ -d "${workspace_dir}" ]] || fail "The workspace directory does not exist. ${workspace_dir}"
[[ -z "${scratch_dir:-}" ]] && scratch_dir="${workspace_dir}/../$(basename "${workspace_dir}").scratch"
scratch_dir="$(normalize_path "${scratch_dir}")"
starting_dir="${PWD}"

cleanup() {
  cd "${starting_dir}"
}
trap cleanup EXIT


# MARK - Create the scratch directory

# Create the scratch directory
rm -rf "${scratch_dir}"
mkdir -p "${scratch_dir}"

# Change to the workspace dir
cd "${workspace_dir}"

# Copy the files. All but the top-level hidden files will be copied.
cp -R -L ./* "${scratch_dir}"

# Copy the top-level, hidden files.
find . -maxdepth 1 \( -type f -or -type l \) -name ".*" -print0 | xargs -0 -I {} cp {} "${scratch_dir}/"

# Output the scratch directory
echo "${scratch_dir}"
