# MyEngFlow Helm Charts

This repository hosts the source code, build rules, and releases for the Helm Charts of [MyEngFlow
Mini][1].

## Licensing

Everything in this repo is licensed under the Apache 2.0 license. See the `LICENSE` file.

The deployment pulls some Docker containers. These may have their own respective licenses. You can
find the container references in the Helm Chart template.

## Purpose

EngFlow's goal with open-sourcing this Helm Chart is to ease the deployment of [MyEngFlow Mini][1]
on a Kubernetes cluster.

## Prerequisites

To install a release version of our Helm Chart:
- Install the Helm Binary (<https://helm.sh/>). You need it to operate (install, update, etc.) our
  Helm Chart(s).
- Sign up on the [MyEngFlow website][1].
    - As of 2024-03-06 sign-up is restricted and not yet available publicly.
    - During sign-up you get a unique key ("cluster UUID"), which is required to operate MyEngFlow
      Mini.

To build a Helm chart from source:
- Install [Bazelisk][2]. Alternatively, install [Bazel][3] 6.3 or newer (a version that supports
  [Bazel modules][4]).

## Building from source

### Debug build (unversioned)

```bash
bazel build chart
```

### Release build (versioned)

```bash
app_version="1.2.3"     # replace with actual version
chart_version="4.5.6"   # replace with actual version

bazel build \
    -c opt \
    --workspace_status_command="echo 'STABLE_VERSION ${app_version}\nSTABLE_CHART_VERSION ${chart_version}'" \
    -- \
    //chart
```

### Notes

Both the "debug" and "release" builds create `bazel-bin/chart/myengflow-mini.tgz`, a Helm Chart
file.

The output file name doesn't follow the convention of Helm Charts: it has no version string. The
proper name would be `myengflow-mini-1.2.3.tgz`. But we can't do that: the output name must be known
before the build (so we can write the BUILD file accordingly) while the version is a build-time user
input.

## Disclaimer

For every Helm Chart that we offer for download in this repo:

- The Helm Chart we provide is AS-IS without warranty of any kind. We provide the file's SHA-256
  digest here, so you can verify the file's integrity after downloading it.
- You are free to inspect the Helm Chart in any way, and with any tool you like. You are free to
  make changes to the code contained in it, or build new Helm Charts based on it.
- We are not responsible for any damage or unwanted consequence of downloading, inspecting,
  installing, or otherwise using the Helm Chart. It is your responsibility to verify the Chart's
  integrity and contents before you do anything with it and you assume all risk and responsibility
  for all results arising from your use of the Helm Chart.
- When you install our Helm Chart, it will make changes to your Kubernetes cluster. In particular,
  it will:
  - Create Kubernetes resources in your cluster, for which there will be cloud resources allocated
    (e.g. on AWS: an Elastic Load Balancer and an Elastic Block Storage volume), which you'll be
    charged for.
  - Create Kubernetes resources in a namespace picked by you.
- When you run the Helm Binary, it will have the same powers over your Kubernetes cluster as you do.
- The deployment will pull and run Docker containers from:
  - The Docker Hub, in order to create necessary files for user authentication. We are not
    responsible for the contents of these containers or for harm that results from running them. You
    can find out the container labels by inspecting the templates in our Helm Chart, and you can
    decide whether you trust those containers.
  - EngFlow's repository on ghcr.io, in order to run MyEngFlow Mini, the service you are installing.
 
[1]: https://my.engflow.com/
[2]: https://github.com/bazelbuild/bazelisk/
[3]: https://github.com/bazelbuild/bazel/
[4]: https://bazel.build/external/module
