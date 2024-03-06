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

load("@rules_pkg//:mappings.bzl", "pkg_attributes", "pkg_files", "strip_prefix")
load("@rules_pkg//:pkg.bzl", "pkg_tar")
load("//infra:helm_package.bzl", "helm_package")

helm_package(
    name = "chart",
    src = ":helm_inputs_tar",
    out = "myengflow-mini.tgz",
    lint_mock_inputs = "mock-inputs.yaml",
    version_file = "//infra:version.gen.txt",
    visibility = [
        "//test/java/com/engflow/re/mini/deploy/helm:__pkg__",
    ],
)

pkg_files(
    name = "helm_inputs",
    srcs = [
        "Chart.yaml",
        "README.md",
        "templates/NOTES.txt",
        "values.yaml",
    ] + glob(["templates/*.yaml"]),
    attributes = pkg_attributes(mode = "0444"),
    strip_prefix = strip_prefix.from_pkg(),
)

pkg_tar(
    name = "helm_inputs_tar",
    srcs = [":helm_inputs"],
)
