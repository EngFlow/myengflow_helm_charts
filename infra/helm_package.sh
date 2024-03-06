#!/usr/bin/env bash

# Copyright 2024 EngFlow, Inc. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Runs Helm (https://helm.sh/) to create a Helm chart.
#
# Do not run this directly; meant to be executed as part of the helm_package() rule.
#
# The helm binary for the current execution platform is passed as a parameter.
# This script doesn't data-depend on Helm, instead it expects something else to stage Helm's runfiles.

set -o pipefail -o nounset -o errexit

# Path to the helm binary, e.g. "external/helm_linux_x64/linux-amd64/helm"
HELM_BIN="$1"

# Path to a tar archive with all the inputs for Helm, arranged as Helm expects.
# Contents should be:
# ├── Chart.yaml   --- Chart definition
# ├── README.md    --- Chart README
# ├── templates    --- Kubernetes deployment files
# │   └── *.yaml
# └── values.yaml  --- Chart inputs
INPUT_TAR="${PWD}/$2"

# Path to a text file containing a single line: a semantic version.
# Used as the --version and --app-version parameters for Helm.
VERSION_FILE="$3"

# Path to the output Helm chart archive.
OUTPUT_TGZ="$4"

# Path to a yaml file with mock input values for the Chart.
#
# If specified, the script passes them to the chart linter, to avoid the linter's errors about
# missing input values.
LINT_VARS_YAML="${5:-}"

function main() {
    local -r exec_root="${PWD}"
    local -r app_version="$(grep "^APP_VERSION=" "${VERSION_FILE}" | cut -d= -f2)"
    local -r chart_version="$(grep "^CHART_VERSION=" "${VERSION_FILE}" | cut -d= -f2)"

    local -r work_dir="$(mktemp -d)"
    trap "rm -rf \"${work_dir}\"" EXIT

    cd "${work_dir}"
    tar xf "${INPUT_TAR}"
    cd "${exec_root}"

    "${HELM_BIN}" package --destination "${work_dir}" --version "${chart_version}" --app-version "${app_version}" "${work_dir}"
    echo >&2 "Built $(ls "${work_dir}"/*.tgz)"
    mv "${work_dir}"/*.tgz "${OUTPUT_TGZ}"

    if [[ -n "${LINT_VARS_YAML:-}" ]]; then
        "${HELM_BIN}" lint --values "${LINT_VARS_YAML}" "${OUTPUT_TGZ}"
    else
        "${HELM_BIN}" lint "${OUTPUT_TGZ}"
    fi
}

main
