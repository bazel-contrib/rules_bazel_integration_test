#!/usr/bin/env bash

fail() {
  local err_msg="${1:-}"
  [[ -n "${err_msg}" ]] || err_msg="Unspecified error occurred."
  echo >&2 "${err_msg}"
  exit 1
}

assert_equal() {
  local expected="${1}"
  local actual="${2}"
  local err_msg="${3:-Expected to be equal. expected: ${expected}, actual: ${actual}}"
  [[ "${expected}" == "${actual}" ]] || fail "${err_msg}"
}

