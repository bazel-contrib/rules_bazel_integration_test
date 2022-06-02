set -uo pipefail

output=$($BIT_BAZEL_BINARY --output_user_root=$BIT_OUTPUT_USER_ROOT run //:foo_test)
test "$output" == "Foo Test" || {
    >&2 echo "output is wrong: $output" && exit 1;
}
