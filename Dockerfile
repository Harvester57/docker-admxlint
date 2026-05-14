# Cf. https://github.com/Harvester57/docker-cmake/pkgs/container/docker-cmake
ARG BUILDKIT_SBOM_SCAN_STAGE=true
FROM ghcr.io/harvester57/docker-cmake:latest@sha256:b843867063589d3e7086c4a6ca60e906bc46679000ffc2ba7c6d47cf6439ba44 AS builder

ENV DEBIAN_FRONTEND=noninteractive

USER root
RUN \
    apt-get update && \
    apt-get install -y --no-install-recommends libxerces-c-dev xsdcxx git libboost-program-options-dev checkinstall && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

USER nonroot
WORKDIR /home/nonroot

RUN git clone --depth 1 https://github.com/Harvester57/admx-lint.git

WORKDIR /home/nonroot/admx-lint

RUN \
    mkdir build && \
    cd build && \
    cmake .. && \
    make -j$(getconf _NPROCESSORS_ONLN) && \
    checkinstall -D -y --fstrans=yes --install=no --default --nodoc --pkgversion="1.0" --reset-uids=yes --pkgname=admxlint --pkglicense=GPL

FROM dhi.io/debian-base:trixie-dev@sha256:9415967aa0ed8adea8b5c048994259d1982026dca143d0303c7bbe0e11ed67d3

LABEL maintainer="florian.stosse@gmail.com"
LABEL lastupdate="2026-005-14"
LABEL author="Florian Stosse"
LABEL description="ADMX linter, built with CMake 4.2.3 base image"
LABEL license="MIT license"

ENV DEBIAN_FRONTEND=noninteractive

COPY --from=builder /home/nonroot/admx-lint/build/*.deb /

RUN \
    apt-get update && \
    apt-get install -y --no-install-recommends libxerces-c3.2 xsdcxx libboost-program-options1.83.0 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    dpkg -i /*.deb && \
    ldconfig && \
    rm /*.deb && \
    admx-lint --help

USER nonroot
