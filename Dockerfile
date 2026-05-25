# Cf. https://github.com/Harvester57/docker-cmake/pkgs/container/docker-cmake
ARG BUILDKIT_SBOM_SCAN_STAGE=true
FROM ghcr.io/harvester57/docker-cmake:latest@sha256:dddc0dddf8aec3d4cdaba3a89915aab9f99b5c14a1723cb67c8bf7605ebfd256 AS builder

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

FROM dhi.io/debian-base:trixie-dev@sha256:d681ef9078dfc5ad6b1c03e44c2f5ade9a4e2ee0c570ec408495c95b8d35b1ee

LABEL org.opencontainers.image.authors="Florian Stosse <florian.stosse@gmail.com>"
LABEL org.opencontainers.image.created="2026-05-17"
LABEL org.opencontainers.image.description="ADMX linter, built with CMake 4.3.2 base image"
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
