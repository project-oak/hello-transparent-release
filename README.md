# Hello Everyone!

With this repo we showcase [Transparent Release](https://github.com/project-oak/transparent-release); read it together with "Getting Started With Your Repo".

In this repo lives a [Java program](src/main/java/com/example/HelloTransparentRelease.java) printing `Hello Transparent Release` to `stdout`. 

We want to apply Transparent Release on the binary of this Java program.

## Just to check: build the binary from the command line first.

First, we need to make sure to have [Bazel set-up](https://docs.bazel.build/versions/main/tutorial/java.html#before-you-begin).

Then, we can build with

```
bazel build //:HelloTransparentRelease 
```

and run with

```
bazel run //:HelloTransparentRelease
[..]
INFO: Build completed successfully, 1 total action
Hello, Transparent Release!
```

or we run the binary:

```
./bazel-bin/HelloTransparentRelease
```

This is the binary we want to release: our `HelloTransparentRelease` binary.

Now, let's compute a sha256 digest of the `HelloTransparentRelease` binary:

```
sha256sum ./bazel-bin/HelloTransparentRelease
8a87337c16d1386510f9d3dd36a744d267945370e40c18113c78bb67e2934cae HelloTransparentRelease
```

Our goal is to make this hash to be the same for whoever builds the `HelloTransparentRelease` binary. That is why we build a builder Docker image.

## Build a builder Docker image to build the `HelloTransparentRelease` binary.

Our builder Docker image has everything installed to build the `HelloTransparentRelease` binary. 

We need to provide a [Dockerfile](Dockerfile) to build our builder Docker image. To build our builder Docker image we run [`./scripts/docker_build`](./scripts/docker_build).

We named our builder Docker image `'gcr.io/oak-ci/oak:hello-transparent-release'`.

# Build the `HelloTransparentRelease` binary with the builder Docker image.

To build binary we use the [`cmd/build` tool](https://github.com/project-oak/transparent-release#building-binaries-using-the-cmdbuild-tool) from [project-oak/transparent-release](https://github.com/project-oak/transparent-release). 

We configure the  `cmd/build` in [buildconfigs/hello_transparent_release.toml](buildconfigs/hello_transparent_release.toml)

From the checked out [transparent-release](https://github.com/project-oak/transparent-release) repo we call:

```
go run cmd/build/main.go -build_config_path <path-to-hello-transparent-release-repo>/hello-transparent-release/buildconfigs/hello_transparent_release.toml 
```
