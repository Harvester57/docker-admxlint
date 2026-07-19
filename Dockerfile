# Cf. https://github.com/Harvester57/docker-cmake/pkgs/container/docker-cmake
ARG BUILDKIT_SBOM_SCAN_STAGE=true
FROM ghcr.io/harvester57/docker-cmake:latest@sha256:001ddccaab7af1f79d207318d6e75dd7fcd101dd55a97bdb40552eca76a8b1ef AS builder

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

FROM dhi.io/debian-base:trixie-dev@sha256:5c45913e72c90581fc4cca57c3a7cd7dcac2d9fa44fce24fe4cfa342e5ccb7a6

LABEL org.opencontainers.image.authors="Florian Stosse <florian.stosse@gmail.com>"
LABEL org.opencontainers.image.created="2026-06-07"
LABEL org.opencontainers.image.description="ADMX linter, built with CMake 4.3.3 base image"
LABEL org.opencontainers.image.licenses="MIT license"

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
