# E2E Test

The e2e tests are designed to test the use of `rules_bazel_integration_test` by a client. It
demonstrates the minimum requirements needed to use this ruleset.

This package contains integration tests that execute other integration tests defined under the
workspace in the `workspace` directory. The `workspace` directory contains its own child workspace
under the `child_workspace` directory.
