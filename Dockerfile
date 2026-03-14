# Cf. https://github.com/Harvester57/docker-cmake/pkgs/container/docker-cmake
ARG BUILDKIT_SBOM_SCAN_STAGE=true
FROM ghcr.io/harvester57/docker-cmake:latest@sha256:63a4a041a65a4595f4447e14405bedb1808271b9ba700a5e15b567678f82ac15 AS builder

ARG DEBIAN_FRONTEND=noninteractive

USER root
RUN \
    apt-get update && \
    apt-get full-upgrade -y && \
    apt-get install -y --no-install-recommends libxerces-c-dev xsdcxx git libboost-program-options-dev checkinstall

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

FROM dhi.io/debian-base:trixie-dev@sha256:135e45aa54d93f6d065af66ad15e1b27e1263fb830f60ed792a9cc398af2b654

LABEL maintainer="florian.stosse@gmail.com"
LABEL lastupdate="2026-03-08"
LABEL author="Florian Stosse"
LABEL description="ADMX linter, built with CMake 4.2.3 base image"
LABEL license="MIT license"

ARG DEBIAN_FRONTEND=noninteractive

COPY --from=builder /home/nonroot/admx-lint/build/*.deb /

RUN \
    apt-get update && \
    apt-get full-upgrade -y && \
    apt-get install -y --no-install-recommends libxerces-c3.2 xsdcxx libboost-program-options1.83.0 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    dpkg -i /*.deb && \
    ldconfig && \
    rm /*.deb && \
    admx-lint --help

USER nonroot
