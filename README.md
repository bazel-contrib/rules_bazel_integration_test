# Bazel Integration Rules

[![Build](https://github.com/bazel-contrib/rules_bazel_integration_test/actions/workflows/ci.yml/badge.svg?event=schedule)](https://github.com/bazel-contrib/rules_bazel_integration_test/actions/workflows/ci.yml)

This repository contains [Bazel](https://bazel.build/) macros that execute integration tests that
use Bazel (e.g. execute tests in a child workspace).  The macros support running integration tests
with multiple versions of Bazel.

## Table of Contents

<!-- MARKDOWN TOC: BEGIN -->
* [Quickstart](#quickstart)
  * [1. Configure your workspace to use `rules_bazel_integration_test`](#1-configure-your-workspace-to-use-rules_bazel_integration_test)
    * [Recommended: Add dependency to `MODULE.bazel`](#recommended-add-dependency-to-modulebazel)
    * [Legacy: Update `WORKSPACE`](#legacy-update-workspace)
  * [2. List the Bazel versions for testing](#2-list-the-bazel-versions-for-testing)
    * [Recommended: Add Bazel versions to `MODULE.bazel`](#recommended-add-bazel-versions-to-modulebazel)
    * [Legacy: Declare the Bazel binaries in the `WORKSPACE` file](#legacy-declare-the-bazel-binaries-in-the-workspace-file)
  * [3. Configure the deleted packages for the parent workspace](#3-configure-the-deleted-packages-for-the-parent-workspace)
  * [4. Define integration test targets](#4-define-integration-test-targets)
* [Integration Tests That Depend Upon The Parent Workspace](#integration-tests-that-depend-upon-the-parent-workspace)
  * [1. Declare a `filegroup` to represent the parent workspace files](#1-declare-a-filegroup-to-represent-the-parent-workspace-files)
  * [2. Update the integration test targets to include the parent workspace files](#2-update-the-integration-test-targets-to-include-the-parent-workspace-files)
  * [3. Execute the integration tests](#3-execute-the-integration-tests)
* [Custom Test Runner](#custom-test-runner)
* [Bazelisk Bazel Version Formats](#bazelisk-bazel-version-formats)
<!-- MARKDOWN TOC: END -->

## Quickstart

The following provides a quick introduction on how to use the rules in this repository. Also, check
out [the documentation](/doc/), the [integration test defined in this repo](/examples/BUILD.bazel),
and the [custom test runner example](/examples/custom_test_runner) for more information.

### 1. Configure your workspace to use `rules_bazel_integration_test`

#### Recommended: Add dependency to `MODULE.bazel`

If you are using Bazel with bzlmod enabled, add the following snippet to your `MODULE.bazel` file.

<!-- BEGIN MODULE SNIPPET -->
```python
bazel_dep(
    name = "rules_bazel_integration_test",
    version = "0.22.0",
    dev_dependency = True,
)
```
<!-- END MODULE SNIPPET -->

#### Legacy: Update `WORKSPACE`

If you are using Bazel with bzlmod disabled, add the following to your `WORKSPACE` file to add this
repository and its dependencies.

<!-- BEGIN WORKSPACE SNIPPET -->
```python
http_archive(
    name = "rules_bazel_integration_test",
    sha256 = "ea588646ddfcfc4e449b0a80d6f7bfbb812c1799c221b6743fcc2dcdb66bd1e5",
    urls = [
        "https://github.com/bazel-contrib/rules_bazel_integration_test/releases/download/v0.22.0/rules_bazel_integration_test.v0.22.0.tar.gz",
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

### 2. List the Bazel versions for testing

#### Recommended: Add Bazel versions to `MODULE.bazel`

Load the `bazel_binaries` extension and specify the Bazel verions to download.
All version specifiers supported by
[Bazelisk](https://github.com/bazelbuild/bazelisk#how-does-bazelisk-know-which-bazel-version-to-run)
are supported.

```python
bazel_binaries = use_extension(
    "@rules_bazel_integration_test//:extensions.bzl",
    "bazel_binaries",
    dev_dependency = True,
)
bazel_binaries.download(version_file = "//:.bazelversion")
bazel_binaries.download(version = "6.0.0")
bazel_binaries.download(version = "last_green")
use_repo(bazel_binaries, "bazel_binaries")
```

#### Legacy: Declare the Bazel binaries in the `WORKSPACE` file

In the `WORKSPACE` file, add the following to download and prepare the Bazel binaries for
testing.

```python
load("@rules_bazel_integration_test//bazel_integration_test:defs.bzl", "bazel_binaries")

bazel_binaries(versions = [
    "//:.bazelversion",
    "6.0.0",
    "last_green",
])
```

### 3. Configure the deleted packages for the parent workspace

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

### 4. Define integration test targets

For the purposes of this example, lets assume that we have an `examples` directory which contains a
subdirectory called `simple`. The `simple` directory contains another Bazel workspace (i.e. has its
own `WORKSPACE` file) that does not have a dependency on the parent workspace. We want to 
execute tests in the `simple` workspace using different versions of Bazel.

Add the following to the `BUILD.bazel` file in the `examples` directory.

```python
load("@bazel_binaries//:defs.bzl", "bazel_binaries")
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
    bazel_version = bazel_binaries.versions.current,
    test_runner = ":simple_test_runner",
    workspace_path = "simple",
)

# If you want to execute an integration test using multiple versions of Bazel,
# use bazel_integration_tests. It will generate multiple integration test
# targets with names derived from the base name and the bazel version.
bazel_integration_tests(
    name = "simple_test",
    bazel_versions = bazel_binaries.versions.other,
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
                bazel_binaries.versions.other,
            ),
    visibility = ["//:__subpackages__"],
)
```

The above code defines three test targets: `//examples:simple_test`,
`//examples:simple_test_bazel_6_0_0`, and
`//examples:simple_test_bazel_7_0_0-pre_20230215_2`. The `all_integration_tests` target is a test
suite that executes all of the integration tests with a single command:

```sh
# Execute all of the integration tests
$ bazel test //examples:all_integration_tests
```

## Integration Tests That Depend Upon The Parent Workspace

In the quickstart example, the child workspace does not reference the parent workspace. In many
cases, a child workspace will reference the parent workspace using a
[local_path_override](https://bazel.build/rules/lib/globals#local_path_override) declaration in
their `MODULE.bazel` file to demonstrate functionality from the parent workspace. 

```python
# Child MODULE.bazel at examples/simple/MODULE.bazel

# Reference the parent workspace
local_path_override(
    module_name = "my_parent_workspace",
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
        "//foo:all_files",
        "//foo/internal:all_files",
        "//foo/internal/modulemap_parser:all_files",
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
development and CI, then specifying `//:.bazelversion` as one of the integration test versions may
make sense. 

Currently, `rules_bazel_integration_test` only supports Bazel semantic versions in the
`.bazelversion` file. If you are interested in being able to use Bazelisk's `<FORK>/<VERSION>`,
please upvote [this issue](https://github.com/bazel-contrib/rules_bazel_integration_test/issues/67).
If you would like support for another format, please [file an
issue](https://github.com/bazel-contrib/rules_bazel_integration_test/issues/new).


