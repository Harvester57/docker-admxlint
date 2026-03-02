# Cf. https://github.com/Harvester57/docker-cmake/pkgs/container/docker-cmake
ARG BUILDKIT_SBOM_SCAN_STAGE=true
FROM ghcr.io/harvester57/docker-cmake:latest@sha256:618322f8fe91b010a3219dd36480ab38f0089793bb806a5606b0887ce2242892 AS builder

ARG DEBIAN_FRONTEND=noninteractive

USER root
RUN \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        git \
        build-essential \
        pkg-config \
        libxerces-c-dev \
        xsdcxx \
        libboost-program-options-dev \
        libcurl4-gnutls-dev \
        libicu-dev && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

USER nonroot
WORKDIR /home/nonroot

RUN git clone --depth 1 https://github.com/Harvester57/admx-lint.git

WORKDIR /home/nonroot/admx-lint

RUN \
    cmake -S . -B build && \
    cmake --build build

FROM dhi.io/debian-base:trixie-debian13-dev@sha256:135e45aa54d93f6d065af66ad15e1b27e1263fb830f60ed792a9cc398af2b654

LABEL maintainer="florian.stosse@gmail.com"
LABEL lastupdate="2025-12-07"
LABEL author="Florian Stosse"
LABEL description="ADMX linter, built with CMake 4.2.3 base image"
LABEL license="MIT license"

USER root
COPY --from=builder /home/nonroot/admx-lint/build/src/admx-lint /usr/bin

USER nonroot

RUN admx-lint --help