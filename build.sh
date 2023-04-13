#!/usr/bin/env bash

DENO_VERSION=v1.32.4

docker build -t deno-build --build-arg DENO_VERSION="${DENO_VERSION}" --progress=plain --file ./Dockerfile.compile .
# DENO_BUILD_CONTAINER="$(docker create deno-build)"
# docker cp "${DENO_BUILD_CONTAINER}:/deno/target/release/deno" .
# docker rm "${CONTAINER_ID}"
