# Use fixed snapshot of Debian to create a deterministic environment.
# Snapshot tags can be found at https://hub.docker.com/r/debian/snapshot/tags?name=bullseye
ARG debian_snapshot=sha256:0ceb7e5812f23e869df15aa8d7e201eceb3042951fb1263ea08d9933bf6c9681
FROM debian/snapshot@${debian_snapshot}

# Install JDK, as well as curl and ca-certificates to install bazel.
RUN apt-get --yes update && \ 
    apt-get install --no-install-recommends --yes \ 
    ca-certificates \ 
    curl \
    openjdk-11-jdk 

# Use a fixed version of Bazel.
ARG bazel_version=4.2.0
ARG bazel_url=https://storage.googleapis.com/bazel-apt/pool/jdk1.8/b/bazel/bazel_${bazel_version}_amd64.deb
RUN curl --location "${bazel_url}" > bazel.deb \
    && apt-get install --no-install-recommends --yes ./bazel.deb \
    && rm bazel.deb \
    && apt-get clean \
    && bazel version