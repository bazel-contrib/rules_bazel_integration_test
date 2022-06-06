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

create_scratch_dir_sh_location=contrib_rules_bazel_integration_test/tools/create_scratch_dir.sh
create_scratch_dir_sh="$(rlocation "${create_scratch_dir_sh_location}")" || \
    (echo >&2 "Failed to locate ${create_scratch_dir_sh_location}" && exit 1)

assertions_sh_location=cgrindel_bazel_starlib/shlib/lib/assertions.sh
assertions_sh="$(rlocation "${assertions_sh_location}")" || \
    (echo >&2 "Failed to locate ${assertions_sh_location}" && exit 1)
source "${assertions_sh}"

assert_equal "--test-runner" "${1}"
test -f "${2}" || (echo >&2 "Failed to locate test runner: ${2}" && exit 1)

while (("$#")); do
    case "${1}" in
        "--test-runner")
            test_runner="${2}"
            shift 2
            ;;
        "--")
            break
            ;;
        *)
            shift 1
            ;;
    esac
done

output_base="${TEST_TMPDIR%/execroot/*}/bazel_testing/"
mkdir -p "$output_base"
workspace_dir="$output_base/main"
$create_scratch_dir_sh --workspace "$BIT_WORKSPACE_DIR" --scratch "$workspace_dir"

test_runner_abs_path="$( pwd )/$test_runner"

# BIT_BAZEL_BINARY set up already by bazel_integration_test
export BIT_WORKSPACE_DIR="$workspace_dir"
export BIT_OUTPUT_USER_ROOT="$output_base"

cd "$workspace_dir"
$test_runner_abs_path "$@"
