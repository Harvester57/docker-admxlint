# Cf. https://github.com/Harvester57/docker-cmake/pkgs/container/docker-cmake
ARG BUILDKIT_SBOM_SCAN_STAGE=true
FROM ghcr.io/harvester57/docker-cmake:latest@sha256:040fc47cf2b7ba3b7b7b0c7e9eae848af77dbac8d19efb458b3a24e62910bc4c AS builder

ARG DEBIAN_FRONTEND=noninteractive

RUN \
    sudo --preserve-env apt-get update && \
    sudo --preserve-env apt-get full-upgrade -y && \
    sudo --preserve-env apt-get install -y --no-install-recommends libxerces-c-dev xsdcxx git libboost-program-options-dev checkinstall

USER appuser
WORKDIR /home/appuser

RUN git clone --depth 1 https://github.com/Harvester57/admx-lint.git

WORKDIR /home/appuser/admx-lint

RUN \
    mkdir build && \
    cd build && \
    cmake .. && \
    make -j$(getconf _NPROCESSORS_ONLN) && \
    checkinstall -D -y --fstrans=yes --install=no --default --nodoc --pkgversion="1.0" --reset-uids=yes --pkgname=admxlint --pkglicense=GPL

FROM debian:unstable-slim@sha256:ea495742790d8178f062a4748c332e7c48d91a337a1006b14c7a489653324725

LABEL maintainer="florian.stosse@gmail.com"
LABEL lastupdate="2025-12-07"
LABEL author="Florian Stosse"
LABEL description="ADMX linter, built with CMake 4.2.0 base image"
LABEL license="MIT license"

ARG DEBIAN_FRONTEND=noninteractive

RUN \
    apt-get update && \
    apt-get full-upgrade -y && \
    apt-get install -y --no-install-recommends libxerces-c3.2 xsdcxx libboost-program-options1.83.0 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

COPY --from=builder /home/appuser/admx-lint/build/*.deb /

RUN \
    dpkg -i /*.deb && \
    ldconfig && \
    rm /*.deb
