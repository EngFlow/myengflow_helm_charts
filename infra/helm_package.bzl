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

"""helm_package() creates a Helm v3 Chart (see https://helm.sh/)."""

def _impl(ctx):
    tc = ctx.toolchains["//infra:toolchain_type"].helm_info
    tool_inputs, tool_input_manifests = ctx.resolve_tools(tools = [tc.helm_bin])

    inputs = depset([ctx.file.src, ctx.file.version_file], transitive = [tool_inputs])
    args = ctx.actions.args()
    args.add_all([tc.helm_bin.files_to_run.executable.path, ctx.file.src.path, ctx.file.version_file.path, ctx.outputs.out.path])

    if ctx.attr.lint_mock_inputs:
        inputs = depset([ctx.file.lint_mock_inputs], transitive = [inputs])
        args.add(ctx.file.lint_mock_inputs.path)

    ctx.actions.run(
        inputs = inputs,
        outputs = [ctx.outputs.out],
        executable = ctx.attr._packager.files_to_run,
        arguments = [args],
        input_manifests = tool_input_manifests,
    )
    return [DefaultInfo(files = depset([ctx.outputs.out]))]

helm_package = rule(
    implementation = _impl,
    attrs = {
        # Path to a tar archive with all the inputs for Helm, arranged as Helm expects.
        # Contents should be:
        # ├── Chart.yaml   --- Chart definition
        # ├── README.md    --- Chart README
        # ├── templates    --- Kubernetes deployment files
        # │   └── *.yaml
        # └── values.yaml  --- Chart inputs
        "src": attr.label(
            allow_single_file = [".tgz", ".tar.gz", ".tar"],
            mandatory = True,
        ),

        # Path to a text file containing two lines: "APP_VERSION=<version>" and
        # "CHART_VERSION=<version>".
        #
        # Used for the --version and --app-version parameters for Helm.
        "version_file": attr.label(
            allow_single_file = True,
            mandatory = True,
        ),

        # Path to the output Helm chart archive.
        "out": attr.output(
            mandatory = True,
        ),

        # A yaml file with mock Chart input values, for the linter.
        #
        # If the chart requires input values, and we run the linter without specifying a value for
        # them, the linter succeeds but prints errors.
        #
        # You can specify values for those variables in this file, to silence the linter's errors.
        "lint_mock_inputs": attr.label(
            allow_single_file = [".yaml"],
            mandatory = False,
        ),
        "_packager": attr.label(
            executable = True,
            cfg = "exec",
            default = Label("//infra:helm_package"),
        ),
    },
    toolchains = ["//infra:toolchain_type"],
)
