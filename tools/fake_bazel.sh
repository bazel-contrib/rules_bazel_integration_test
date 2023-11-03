#!/usr/bin/env bash

# This executable script acts as a stand-in for a Bazel binary to test 
# `bazel_binaries.local()`. 

set -o errexit -o nounset -o pipefail

echo "Fake Bazel Script:" "$@" | tee -a "fake_bazel.out"
