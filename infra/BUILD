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

load(":helm_toolchain.bzl", "helm_toolchain")

toolchain_type(
    name = "toolchain_type",
    visibility = ["//visibility:public"],
)

[toolchain(
    name = "helm_toolchain_%s_%s" % (os, arch),
    exec_compatible_with = [
        "@platforms//os:%s" % os,
        "@platforms//cpu:%s" % bazel_arch,
    ],
    toolchain = ":helm_bin_%s_%s" % (os, arch),
    toolchain_type = ":toolchain_type",
) for (os, arch, bazel_arch) in [
    ("linux", "x64", "x86_64"),
    ("linux", "arm64", "aarch64"),
    ("macos", "x64", "x86_64"),
    ("macos", "arm64", "aarch64"),
    ("windows", "x64", "x86_64"),
]]

[helm_toolchain(
    name = "helm_bin_%s_%s" % (os, arch),
    helm_bin = "@helm_%s_%s//:helm.exe" % (os, arch),
) for os, arch in [
    ("linux", "x64"),
    ("linux", "arm64"),
    ("macos", "x64"),
    ("macos", "arm64"),
    ("windows", "x64"),
]]

sh_binary(
    name = "helm_package",
    srcs = ["helm_package.sh"],
    visibility = ["//visibility:public"],
)
