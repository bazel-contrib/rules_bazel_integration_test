#!/bin/bash -eu

want="6.1.1"
got="$(cat "${SAMPLE_FILE}")"

if [[ "${want}" != "${got}" ]]; then
    echo >&2 "want '${want}' got '${got}'"
    exit 1
fi
