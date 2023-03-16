# Bazel Integration Rules

[![Build](https://github.com/bazel-contrib/rules_bazel_integration_test/actions/workflows/ci.yml/badge.svg?event=schedule)](https://github.com/bazel-contrib/rules_bazel_integration_test/actions/workflows/ci.yml)

This repository contains [Bazel](https://bazel.build/) macros that execute integration tests that
use Bazel (e.g. execute tests in a child workspace).  The macros support running integration tests
with multiple versions of Bazel.

## Table of Contents

* [Quickstart](#quickstart)
  * [1\. Configure your workspace to use rules\_bazel\_integration\_test](#1-configure-your-workspace-to-use-rules_bazel_integration_test)
  * [2\. Create a bazel\_versions\.bzl in the root of your repository](#2-create-a-bazel_versionsbzl-in-the-root-of-your-repository)
  * [3\. Declare the Bazel binaries in the WORKSPACE file](#3-declare-the-bazel-binaries-in-the-workspace-file)
  * [4\. Configure the deleted packages for the parent workspace](#4-configure-the-deleted-packages-for-the-parent-workspace)
  * [5\. Define integration test targets](#5-define-integration-test-targets)
* [Integration Tests That Depend Upon The Parent Workspace](#integration-tests-that-depend-upon-the-parent-workspace)
  * [1\. Declare a filegroup to represent the parent workspace files](#1-declare-a-filegroup-to-represent-the-parent-workspace-files)
  * [2\. Update the integration test targets to include the parent workspace files](#2-update-the-integration-test-targets-to-include-the-parent-workspace-files)
  * [3\. Execute the integration tests](#3-execute-the-integration-tests)
* [Custom Test Runner](#custom-test-runner)
* [Bazelisk Bazel Version Formats](#bazelisk-bazel-version-formats)

## Quickstart

The following provides a quick introduction on how to use the rules in this repository. Also, check
out [the documentation](/doc/), the [integration test defined in this repo](/examples/BUILD.bazel),
and the [custom test runner example](/examples/custom_test_runner) for more information.

### 1. Configure your workspace to use `rules_bazel_integration_test`

Add the following to your `WORKSPACE` file to add this repository and its dependencies.

<!-- BEGIN WORKSPACE SNIPPET -->
```python
http_archive(
    name = "rules_bazel_integration_test",
    sha256 = "71eae1efc3ff8c917eb2da73d5c847255672272203790f09649f19dc2aa347f6",
    urls = [
        "https://github.com/bazel-contrib/rules_bazel_integration_test/releases/download/v0.11.0/rules_bazel_integration_test.v0.11.0.tar.gz",
    ],
)

load("@rules_bazel_integration_test//bazel_integration_test:deps.bzl", "bazel_integration_test_rules_dependencies")

bazel_integration_test_rules_dependencies()

load("@cgrindel_bazel_starlib//:deps.bzl", "bazel_starlib_dependencies")

bazel_starlib_dependencies()

load("@bazel_skylib//:workspace.bzl", "bazel_skylib_workspace")

bazel_skylib_workspace()
```
<!-- END WORKSPACE SNIPPET -->

### 2. Create a `bazel_versions.bzl` in the root of your repository

Add the following to a file called `bazel_versions.bzl` at the root of your repository. Replace the
Bazel version values with the values that you would like to test against for your integration tests.

```python
# If you are using Bazelisk for your project, you can specify that the current 
# Bazel version be retrieved from the `.bazelversion` file. Otherwise, specify
# a valid semantic version. 
CURRENT_BAZEL_VERSION = "//:.bazelversion"

OTHER_BAZEL_VERSIONS = [
    "4.2.2",
    "6.0.0-pre.20220328.1",
]

SUPPORTED_BAZEL_VERSIONS = [
    CURRENT_BAZEL_VERSION,
] + OTHER_BAZEL_VERSIONS
```

NOTE: The above code designates a current version and other versions. This can be useful if you have
a large number of integration tests where you want to execute all of them against the current
version and execute a subset of them against other Bazel versions.

NOTE: For more information on supported Bazelisk Bazel version formats, please see [Bazelisk Bazel
Version Formats](#bazelisk-bazel-version-formats).

Add the following to the Bazel build file in the same package as the `bazel_versions.bzl` file.

```python
load("@bazel_skylib//:bzl_library.bzl", "bzl_library")

bzl_library(
    name = "bazel_versions",
    srcs = ["bazel_versions.bzl"],
    visibility = ["//:__subpackages__"],
)
```

### 3. Declare the Bazel binaries in the `WORKSPACE` file

Back in the `WORKSPACE` file, add the following to download and prepare the Bazel binaries for
testing.

```python
load("//:bazel_versions.bzl", "SUPPORTED_BAZEL_VERSIONS")
load("@rules_bazel_integration_test//bazel_integration_test:defs.bzl", "bazel_binaries")

bazel_binaries(versions = SUPPORTED_BAZEL_VERSIONS)
```

### 4. Configure the deleted packages for the parent workspace

If you have child workspaces under your parent workspace, you need to tell Bazel to ignore the child
workspaces. This can be done in one of two ways:

1. Add entries to the `.bazelignore` file in the parent workspace.
2. Specify a list of deleted packages using the `--deleted_packages` flag.

For `glob()` in the parent workspace to find files in the child workspaces, we need to use the
deleted packages mechanism.

Add the following to the `.bazelrc` in the parent workspace. Leave the values blank for now.

```conf
# To update these lines, execute 
# `bazel run @rules_bazel_integration_test//tools:update_deleted_packages`
build --deleted_packages=
query --deleted_packages=
```

To populate the values, we will run a utility that looks for child workspaces (i.e., `WORKSPACE`
files) and find all of the directories that have Bazel build files (i.e., `BUILD`, `BUILD.bazel`).
Execute the following in a parent workspace directory.

```sh
# Populate the --deleted_packages flags in the .bazelrc
$ bazel run @rules_bazel_integration_test//tools:update_deleted_packages
```

After running the utility, the `--deleted_packages` entries in the `.bazelrc` should have a
comma-separated list of packages under the child workspaces. 

### 5. Define integration test targets

For the purposes of this example, lets assume that we have an `examples` directory which contains a
subdirectory called `simple`. The `simple` directory contains another Bazel workspace (i.e. has its
own `WORKSPACE` file) that does not have a dependency on the parent workspace. We want to 
execute tests in the `simple` workspace using different versions of Bazel.

Add the following to the `BUILD.bazel` file in the `examples` directory.

```python
load("//:bazel_versions.bzl", "CURRENT_BAZEL_VERSION", "OTHER_BAZEL_VERSIONS")
load(
    "@rules_bazel_integration_test//bazel_integration_test:defs.bzl",
    "bazel_integration_test",
    "bazel_integration_tests",
    "default_test_runner",
    "integration_test_utils",
)

# Declare a test runner to drive the integration tests.
default_test_runner(
    name = "simple_test_runner",
)

# If you only want to execute against a single version of Bazel, use
# bazel_integration_test.
bazel_integration_test(
    name = "simple_test",
    bazel_version = CURRENT_BAZEL_VERSION,
    test_runner = ":simple_test_runner",
    workspace_path = "simple",
)

# If you want to execute an integration test using multiple versions of Bazel,
# use bazel_integration_tests. It will generate multiple integration test
# targets with names derived from the base name and the bazel version.
bazel_integration_tests(
    name = "simple_test",
    bazel_versions = OTHER_BAZEL_VERSIONS,
    test_runner = ":simple_test_runner",
    workspace_path = "simple",
)

# By default, the integration test targets are tagged as `manual`. This
# prevents the targets from being found from most target expansion (e.g.
# `//...`, `:all`). To easily execute a group of integration tests, you may
# want to define a test suite which includes the desired test targets.
test_suite(
    name = "all_integration_tests",
    # If you don't apply the test tags to the test suite, the test suite will
    # be found when `bazel test //...` is executed.
    tags = integration_test_utils.DEFAULT_INTEGRATION_TEST_TAGS,
    tests = [":simple_test"] +
            integration_test_utils.bazel_integration_test_names(
                "simple_test",
                OTHER_BAZEL_VERSIONS,
            ),
    visibility = ["//:__subpackages__"],
)
```

The above code defines three test targets: `//examples:simple_test`,
`//examples:simple_test_bazel_5_0_0-pre_20211011_2`, and
`//examples:simple_test_bazel_6_0_0-pre_20211101_2`. The `all_integration_tests` target is a test
suite that executes all of the integration tests with a single command:

```sh
# Execute all of the integration tests
$ bazel test //examples:all_integration_tests
```

## Integration Tests That Depend Upon The Parent Workspace

In the quickstart example, the child workspace does not reference the parent workspace. In many
cases, a child workspace will reference the parent workspace using a
[local_repository](https://docs.bazel.build/versions/main/be/workspace.html#local_repository)
declaration to demonstrate functionality from the parent workspace. 

```python
# Child WORKSPACE at examples/simple/WORKSPACE

# Reference the parent workspace
local_repository(
    name = "my_parent_workspace",
    path = "../..",
)
```

This section explains how to use `rules_bazel_integration_test` in this situation. To review working
examples, check out [bazel-starlib](https://github.com/cgrindel/bazel-starlib) and
[swift_bazel](https://github.com/cgrindel/swift_bazel).

### 1. Declare a `filegroup` to represent the parent workspace files

The child workspace needs to access parent workspace files. To easily reference the files, declare a
`filegroup` at the root of the parent workspace to collect all of the files that the child workspace
needs. The values listed in the `srcs` should include every file and/or package that the child
workspaces require.

```python
# This target collects all of the parent workspace files needed by the child workspaces.
filegroup(
    name = "local_repository_files",
    # Include every package that is required by the child workspaces.
    srcs = [
        "BUILD.bazel",
        "WORKSPACE",
        "//spm:all_files",
        "//spm/internal:all_files",
        "//spm/internal/modulemap_parser:all_files",
    ],
    visibility = ["//:__subpackages__"],
)
```

In every parent workspace package that is listed in the `srcs` above, create a filegroup globbing
all of the files in the package.

```python
# Add to every package that is required by a child workspace.
filegroup(
    name = "all_files",
    srcs = glob(["*"]),
    visibility = ["//:__subpackages__"],
)
```

### 2. Update the integration test targets to include the parent workspace files

The [`bazel_integration_test`](/doc/rules_and_macros_overview.md#bazel_integration_test) and
[`bazel_integration_tests`](/doc/rules_and_macros_overview.md#bazel_integration_tests) declarations
include a `workspace_files` attribute. If not specified, it defaults to a custom glob expression
selecting files under the child workspace directory. To include the parent workspace files, add the
attribute with an expression that globs the workspace files and the `//:local_repository_files`
target.

```python
bazel_integration_test(
    name = "simple_test",
    bazel_version = CURRENT_BAZEL_VERSION,
    test_runner = ":simple_test_runner",
    workspace_files = integration_test_utils.glob_workspace_files("simple") + [
        "//:local_repository_files",
    ],
    workspace_path = "simple",
)
```

### 3. Execute the integration tests

Execute the integration test.

```sh
# Execute the integration test called simple_test
$ bazel test //examples:simple_test
```

## Custom Test Runner

For information on implementing a custom test runner, please see [the
documentation](/doc/custom_test_runners.md).

## Bazelisk Bazel Version Formats

Bazel integration tests require a Bazel version or a Bazel binary to use for the execution of an
integration test. Bazel version values can be a Bazel semantic version or a reference to a file that
contains a Bazel semantic version (e.g., `//:.bazelversion`). If you are using
[Bazelisk](https://github.com/bazelbuild/bazelisk) to specify the version of Bazel for use in
development and CI, then specifying `//:.bazelversion` as one of integration test versions may make
sense. 

Currently, `rules_bazel_integration_test` only supports Bazel semantic versions in the
`.bazelversion` file. If you are interested in being able to use Bazelisk's `<FORK>/<VERSION>`,
please upvote [this issue](https://github.com/bazel-contrib/rules_bazel_integration_test/issues/67).
If you would like support for another format, please [file an
issue](https://github.com/bazel-contrib/rules_bazel_integration_test/issues/new).


