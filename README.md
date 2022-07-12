# Hello, Stranger!

With this repo we showcase [Transparent Release](https://github.com/project-oak/transparent-release); read it together with [Getting Started With Your Repo](?).

In this repo lives a `[Java program](src/main/java/com/example/HelloTransparentRelease.java)` printing `Hello Transparent Release` to `stdout`. 

We want to apply Transparent Release on the binary of this Java Program.

First, we need to build the binary:

## Run from your command line

Make sure you have [Bazel set-up](https://docs.bazel.build/versions/main/tutorial/java.html#before-you-begin).

Then, you can build with

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

or you run the binary:

```
bazel-bin/HelloTransparentRelease
```

This binary we want to release!

Now, let's compute a sha256 digest of the binary:

```
$ sha256sum HelloTransparentRelease
8a87337c16d1386510f9d3dd36a744d267945370e40c18113c78bb67e2934cae  HelloTransparentRelease
```