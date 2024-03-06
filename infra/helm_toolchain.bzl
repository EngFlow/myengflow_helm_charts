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

"""Defines a Helm v3 toolchain; see https://helm.sh/."""

HelmInfo = provider(
    "Defines a Helm v3 toolchain; see https://helm.sh/.",
    fields = ["helm_bin"],
)

def _impl(ctx):
    return [
        platform_common.ToolchainInfo(
            helm_info = HelmInfo(
                helm_bin = ctx.attr.helm_bin,
            ),
        ),
    ]

helm_toolchain = rule(
    implementation = _impl,
    attrs = {
        "helm_bin": attr.label(
            allow_single_file = True,
            executable = True,
            cfg = "exec",
        ),
    },
)
