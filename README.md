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
1. [Create a buildconfig file](#create-a-buildconfig-file)
1. [Create a GitHub Actions workflow to call the container-based SLSA3 builder](#create-a-github-actions-workflow)
1. [Run the builder tool locally](#run-the-builder-tool-locally)
1. [Create a custom Docker image to use with the container-based SLSA3 builder](#create-a-custom-docker-image)

## The things you need

To use the container-based SLSA3 builder, you need

1. An OCI builder image, in which the build commands for building the binary are executed
1. A buildconfig file, containing the build configuration info
1. A GitHub actions workflow to call the container-based SLSA3 builder.

For the most of this tutorial, we will use a pre-built Maven Docker image. But
you can, as well, use a custom image, as described
[below](#create-a-custom-docker-image).

## Create a buildconfig file

## Create a GitHub Actions workflow

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
