<!-- Logo Start -->
<!-- An HTML element is intentionally used since GitHub recommends this approach to handle different images in dark/light modes. Ref: https://docs.github.com/en/get-started/writing-on-github/getting-started-with-writing-and-formatting-on-github/basic-writing-and-formatting-syntax#specifying-the-theme-an-image-is-shown-to -->
<!-- markdownlint-disable-next-line MD033 -->
<h1><picture><source media="(prefers-color-scheme: dark)" srcset="https://github.com/project-oak/oak/blob/main/docs/oak-logo/svgs/oak-transparent-release-negative-colour.svg?sanitize=true"><source media="(prefers-color-scheme: light)" srcset="https://github.com/project-oak/oak/blob/main/docs/oak-logo/svgs/oak-transparent-release.svg?sanitize=true"><img alt="Project Oak Logo" src="docs/oak-logo/svgs/oak-logo.svg?sanitize=true"></picture></h1>
<!-- Logo End -->

With this `hello-transparent-release` repo we showcase the user of the
[Container-based SLSA3 builder](https://github.com/slsa-framework/slsa-github-generator/tree/main/internal/builders/docker),
which uses a `Docker-based build tool`. This tool used to be part of the
[Transparent Release](https://github.com/project-oak/transparent-release)
project, hence the name of this repo :smile:

In this repo lives a
[Java program](src/main/java/com/example/HelloTransparentRelease.java)
printing `Hello Transparent Release` to `stdout`.

We want to apply use the Container-based SLSA3 builder to build the binary of
this Java program, and generate a non-forgeable provenance statement for the
built binary.

For this we are going to do the following:

1. [The things you need](#the-things-you-need)
1. [The Docker-based build tool](#the-docker-based-build-tool)
1. [Create a buildconfig file](#create-a-buildconfig-file)
1. [Create a GitHub Actions workflow to call the container-based SLSA3 builder](#create-a-github-actions-workflow)
1. [Run the builder tool locally](#run-the-builder-tool-locally)
1. [Create a custom Docker image to use with the container-based SLSA3 builder](#create-a-custom-docker-image)

## The things you need

To use the container-based SLSA3 builder, you need

1. An OCI builder image, in which the build commands for building the binary
   are executed.
1. A GitHub repository containing your source code.
1. A buildconfig file, containing the build configuration info.
1. A GitHub actions workflow to call the container-based SLSA3 builder.

For the most of this tutorial, we will use a pre-built Maven Docker image. But
you can, as well, use a custom image, as described
[below](#create-a-custom-docker-image).

## The Docker-based build tool

The Docker-based build tool uses Docker CLI to build one or more binaries from
your source code. It is used by the container-based SLSA3 builder to build your
binaries, but you can also use it locally for testing.

The Docker-based build tool first fetches the source code from your Git
repository at a given commit hash. When called by the container-based SLSA3
builder, the commit hash is taken from the GitHub context, and you does not
have to explicitly provide it. When running it locally, you have to explicitly
specify the SHA1 digest of the Git commit as one of the inputs to the tool.

Once the Git repository is fetched and checked-out at the given commit,
Docker-based build tool uses the `docker run` command, with OCI builder image
and a command. You have to explicitly specify the OCI builder image both when
using container-based SLSA3 builder, and when using the Docker-based build tool
locally.

Similarly, in both cases, you have to explicitly specify the command, by
including it in a buildconfig file, that you provide as input to
container-based SLSA3 builder or directly to Docker-based build tool, when
using it locally.

## Create a buildconfig file

A buildconfig file is a simple `toml` file that currently is required to
contain only two fields: `command` and `artifact_path`. In the future, we may
add support for additional optional build configuration information.

`command` is a string array containing the command that will be passed to
`docker run` together with the builder image (e.g., the Maven image mentioned
above). The `docker run` runs at the root of your Git repository and is
expected to build one or more files (binaries or other software artifacts) in a
path under the root of your repository.

`artifact_path` is a path, relative to the root of your repository, where you'd
expect to find the built files once the execution of the `docker run` command
is completed. You can use wildcards to specify the path. This is useful when
your command generates multiple files.

[Here](buildconfigs/hello_transparent_release_mvn.toml) is the buildconfig we
use for building the `hello-transparent-release` binary as a `jar` file.

## Create a GitHub Actions workflow

Now we have everything that we need to use the
[Container-based SLSA3 builder](https://github.com/slsa-framework/slsa-github-generator/tree/main/internal/builders/docker).

The workflow that we use in this repository contains a single job:

```yaml
jobs:
  generate_provenance:
    permissions:
      actions: read
      id-token: write
      contents: write
    uses: slsa-framework/slsa-github-generator/.github/workflows/builder_docker-based_slsa3.yml@main
    with:
      builder-image: "maven"
      builder-digest: "sha256:0c7eb85349cecff10e865ef298bdef117024e931b7ad9a4e527d41c897a6a779"
      config-path: "buildconfigs/hello_transparent_release_mvn.toml"
      provenance-name: "hello_transparent_release.intoto"
      compile-builder: true
```

Here we have specified the builder image by its name (`maven`) and digest
(`sha256:0c7eb85349cecff10e865ef298bdef117024e931b7ad9a4e527d41c897a6a779`).
You can find this information on the container registry that you intend to use.

The third input parameter is `config-path` which is the path to the buildconfig
file that we created above.

The next input parameter is provided for convenience. We have specified a
custom name for the provenance that the container-based SLSA3 builder
generates. This is useful where you have multiple jobs in your workflow, each
building and generating a provenance for a different binary.

Note that while the workflow is called the "container-based SLSA3 builder", the
file where this reusable workflow is implemented is called
`builder_docker-based_slsa3.yml`! This is to be explicit about the use of the
`Docker-based build tool` in this workflow.

See the complete workflow [here](.github/workflows/provenance.yaml).
We run this workflow both on pull-request events, and on push events. But only
the provenances that are generated on push events are signed.

For a detailed description about how to use the container-based SLSA3 builder,
see
[this documentation](https://github.com/slsa-framework/slsa-github-generator/tree/main/internal/builders/docker).

## Run the builder tool locally

### Fetch the Docker-based build tool

Update:

```bash
wget https://github.com/project-oak/transparent-release/releases/download/v0.1/transparent-release_0.1_Linux_x86_64.tar.gz
tar -xvzf transparent-release_0.1_Linux_x86_64.tar.gz
./transparent-release  -build_config_path ./buildconfigs/hello_transparent_release.toml
```

### Some useful flags

### The binary

The sha256 digest of the binary:

```bash
hello-transparent-release/out$ sha256sum HelloTransparentRelease
e8e05d1d09af8952919bf6ab38e0cc5a6414ee2b5e21f4765b12421c5db0037e  HelloTransparentRelease
```

This should now be the same on your machine! Please let us know if not!

### The build definition

## Create a custom Docker image

So far, we have been relying on a pre-built Maven image for building the binary. However, you could use a custom image with the container-based SLSA3 builder. One way to create a custom image is to use a Dockerfile. In this section, we walk you through creating a custom builder image using a Dockerfile.

This time, we are going to build the binary using Bazel instead of Maven.

### [Optional] Build the binary from the command line

First, we need to make sure to have [Bazel set-up](https://docs.bazel.build/versions/main/tutorial/java.html#before-you-begin).

Then, we can build with

```bash
./scripts/build
```

We run the binary:

```bash
./out/HelloTransparentRelease
```

This is the binary we want to release: our `HelloTransparentRelease` binary.

Now, let's compute a sha256 digest of the `HelloTransparentRelease` binary:

```bash
sha256sum ./out/HelloTransparentRelease
8a87337c16d1386510f9d3dd36a744d267945370e40c18113c78bb67e2934cae HelloTransparentRelease
```

This sha256 digest might or might not be the same on your machine.

Our goal is to make this to be the same for whoever builds the `HelloTransparentRelease` binary.

That is why we build a builder Docker image that has everything installed to build the `HelloTransparentRelease` binary.

### Build a builder Docker image

We need to provide a [Dockerfile](Dockerfile) to build our builder Docker image. We name our Docker image `hello-transparent-release`.

We want the `HelloTransparentRelease` binary built by the builder Docker image to have the same permissions as the user. To do so, we use [rootless Docker](https://docs.docker.com/engine/security/rootless/).

To build our builder Docker image we run [`./scripts/docker_build`](./scripts/docker_build).

Our builder Docker image has to be publicly available, so we push it to a registry ([given the right permissions](https://github.com/project-oak/hello-transparent-release/blob/16dafa1fa125db3c40bbb5794044e790936a6656/scripts/docker_push#L3-L12)): [europe-west2-docker.pkg.dev/oak-ci/hello-transparent-release/](https://pantheon.corp.google.com/artifacts/docker/oak-ci/europe-west2/hello-transparent-release) with [`./scripts/docker_push`](./scripts/docker_push).

We can now see the latest builder Docker image [here](https://pantheon.corp.google.com/artifacts/docker/oak-ci/europe-west2/hello-transparent-release?project=oak-ci).

Pushing the Docker image to a registry will give us a manifest and a `DIGEST` to identify the image [published in the registry](https://pantheon.corp.google.com/artifacts/docker/oak-ci/europe-west2/hello-transparent-release/hello-transparent-release?project=oak-ci). We will need this digest to configure the `cmd/builder` tool.

```bash
sha256:d682d6f0f2bbec373f4a541b55c03d43e52e774caa40c4b121be6e96b5d01f56
```

### Use the custom builder Docker in the GitHub workflow

#### Configuring the `cmd/builder` tool

The buildconfig in [buildconfigs/hello_transparent_release.toml](buildconfigs/hello_transparent_release.toml) holds the configuration for `cmd/builder`.
