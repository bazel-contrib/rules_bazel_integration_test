#!/usr/bin/env bash

# This script is sourced by tests that need a parent workspace with child workspaces.

parent_dir="${PWD}/parent"
examples_dir="${parent_dir}/examples"

child_a_dir="${examples_dir}/child_a"
child_a_pkg_dir="${child_a_dir}/foo"

child_b_dir="${parent_dir}/somewhere_else/child_b"
child_b_pkg_dir="${child_b_dir}/bar"

child_c_dir="${parent_dir}/somewhere_else/child_c"
child_c_pkg_dir="${child_c_dir}/baz"

directories=("${parent_dir}" "${examples_dir}" "${child_a_dir}" "${child_b_dir}" "${child_c_dir}")
directories+=("${child_a_pkg_dir}" "${child_b_pkg_dir}" "${child_c_pkg_dir}")
for dir in "${directories[@]}" ; do
  mkdir -p "${dir}"
done

parent_workspace="${parent_dir}/WORKSPACE"
child_a_workspace="${child_a_dir}/WORKSPACE"
child_b_workspace="${child_b_dir}/WORKSPACE"
child_c_workspace="${child_c_dir}/WORKSPACE"
workspaces=("${parent_workspace}" "${child_a_workspace}" "${child_b_workspace}" "${child_c_workspace}")
for workspace in "${workspaces[@]}" ; do
  touch "${workspace}"
done

parent_build="${parent_dir}/BUILD.bazel"
examples_build="${examples_dir}/BUILD.bazel"
child_a_build="${child_a_dir}/BUILD"
child_a_pkg_build="${child_a_pkg_dir}/BUILD"
child_b_pkg_build="${child_b_pkg_dir}/BUILD.bazel"
child_c_build="${child_c_dir}/BUILD"
child_c_pkg_build="${child_c_pkg_dir}/BUILD"
build_files=("${parent_build}" "${examples_build}" "${child_a_build}" "${child_a_pkg_build}")
build_files+=("${child_b_pkg_build}" "${child_c_build}" "${child_c_pkg_build}")
for build_file in "${build_files[@]}" ; do
  touch "${build_file}"
done

parent_bazelrc="${parent_dir}/.bazelrc"
child_a_bazelrc="${child_a_dir}/.bazelrc"
child_b_bazelrc="${child_b_dir}/.bazelrc"
child_c_bazelrc="${child_c_dir}/.bazelrc"
child_bazelrcs=("${child_a_bazelrc}" "${child_b_bazelrc}" "${child_c_bazelrc}")
bazelrcs=("${parent_bazelrc}" "${child_a_bazelrc}" "${child_b_bazelrc}" "${child_c_bazelrc}")
# Added BOF and EOF comments to make it easier to see the beginning and end of files when debugging
# failed assertions.
bazelrc_template="
# BOF
build --deleted_packages=
query --deleted_packages=
# EOF"

reset_bazelrc_files() {
  for bazelrc in "${bazelrcs[@]}" ; do
    echo "${bazelrc_template}" > "${bazelrc}"
  done
}
reset_bazelrc_files
