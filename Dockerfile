# Cf. https://github.com/Harvester57/docker-cmake/pkgs/container/docker-cmake
ARG BUILDKIT_SBOM_SCAN_STAGE=true
FROM ghcr.io/harvester57/docker-cmake:latest@sha256:ba127929e25baf9e7042a44229efd5f573f3664f23081735c17b38b3a90fb410 AS builder

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

FROM debian:unstable-slim@sha256:5ee6733c2db5bfe27184aaf83db7611fca0652706fd93704422b1a890ae2db73

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
