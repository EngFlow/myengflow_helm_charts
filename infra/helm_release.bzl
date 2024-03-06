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

"""A Bazel Module Extension that creates a http_archive for a Helm release binary.

For info about:
- Bazel Module Extensions, see https://bazel.build/external/extension
- Helm, see https://helm.sh/ 
"""

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

_BUILD_FILE_CONTENT = """
alias(
    name = "helm{ext}",
    actual = "{os}-{arch}/helm{ext}",
    visibility = ["//visibility:public"]
)
"""

def _impl(ctx):
    repo_names = {}

    for mod in ctx.modules:
        for e in mod.tags.declare_binary:
            if e.name in repo_names:
                # Avoid creating the same repo twice, in case multiple modules declare it.
                continue

            repo_names[e.name] = True

            http_archive(
                name = e.name,
                build_file_content = _BUILD_FILE_CONTENT.format(
                    os = e.upstream_os,
                    arch = e.upstream_arch,
                    ext = e.exe_extension,
                ),
                sha256 = e.sha256,
                urls = [
                    "https://get.helm.sh/helm-v{version}-{os}-{arch}.{archive_type}".format(
                        os = e.upstream_os,
                        arch = e.upstream_arch,
                        version = e.version,
                        archive_type = e.archive_type,
                    ),
                ],
            )

helm_release_extension = module_extension(
    implementation = _impl,
    tag_classes = {
        "declare_binary": tag_class(
            attrs = {
                "name": attr.string(mandatory = True),
                "upstream_os": attr.string(mandatory = True),
                "upstream_arch": attr.string(mandatory = True),
                "version": attr.string(mandatory = True),
                "sha256": attr.string(mandatory = True),
                "archive_type": attr.string(default = "tar.gz"),
                "exe_extension": attr.string(default = ""),
            },
        ),
    },
)
