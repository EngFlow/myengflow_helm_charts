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

# Writes the build variables "STABLE_VERSION" and "STABLE_CHART_VERSION" to the output file as
# "APP_VERSION={STABLE_VERSION}" and "CHART_VERSION={STABLE_CHART_VERSION}".
#
# The output file can be passed to a helm_package() rule's "version_file" attribute.

set -o nounset -o pipefail -o errexit
[[ "${SCRIPT_DEBUG:-"off"}" == "on" ]] && set -o xtrace

OUT_VERSION="${1:?"arg 1 omitted; expecting path to output file version.txt"}"

function get_version() {
  local -r app_version="$(grep '^STABLE_VERSION\b' "./bazel-out/stable-status.txt" |
      cut -d' ' -f2- |
      sed 's/[-_]/./g' ||
      date -u +"%Y-%m-%d-%H-%M-%S")"
  local -r chart_version="$(grep '^STABLE_CHART_VERSION\b' "./bazel-out/stable-status.txt" |
      cut -d' ' -f2- |
      sed 's/[-_]/./g' ||
      echo "${app_version}")"
  echo -e "APP_VERSION=${app_version}\nCHART_VERSION=${chart_version}"
}

mkdir -p "$(dirname "${OUT_VERSION}")"
get_version > "${OUT_VERSION}"
