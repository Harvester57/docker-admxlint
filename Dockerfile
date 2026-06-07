# Cf. https://github.com/Harvester57/docker-cmake/pkgs/container/docker-cmake
ARG BUILDKIT_SBOM_SCAN_STAGE=true
FROM ghcr.io/harvester57/docker-cmake:latest@sha256:72ca80ba756cf21889bb164523cea0357c2f6e6e190b4d175eef634b12d91699 AS builder

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

FROM dhi.io/debian-base:trixie-dev@sha256:41cc0e62bbb3b8cbb29deb40c987e55577cf98c4d00ede32b40159a1a4d87565

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
