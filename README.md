# Hello Everyone!

With this repo we showcase [Transparent Release](https://github.com/project-oak/transparent-release); read it together with "Getting Started With Your Repo".

In this repo lives a [Java program](src/main/java/com/example/HelloTransparentRelease.java) printing `Hello Transparent Release` to `stdout`. 

We want to apply Transparent Release on the binary of this Java Program.

First, we need to build the binary:

## Run from your command line

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

This is the binary we want to release!

Now, let's compute a sha256 digest of the binary:

```
sha256sum ./bazel-bin/HelloTransparentRelease
8a87337c16d1386510f9d3dd36a744d267945370e40c18113c78bb67e2934cae  HelloTransparentRelease
```

## Build a builder Docker image

Next, we use the builder Docker image to build our binary. 

First we need to build our builder Docker image:

```
./scripts/docker_build
```

