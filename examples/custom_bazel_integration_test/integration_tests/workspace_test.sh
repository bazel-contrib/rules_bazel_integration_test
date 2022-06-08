set -uo pipefail

output=$($BIT_BAZEL_BINARY --output_user_root=$BIT_OUTPUT_USER_ROOT run //:foo_test)
test "$output" == "Foo Test" || ( echo >&2 "Output is invalid: $output" && exit 1 )
