# Cf. https://github.com/Harvester57/docker-cmake/pkgs/container/docker-cmake
FROM ghcr.io/harvester57/docker-cmake:latest@sha256:d6c395f0ad877f1398129bb7d061b472064629705ab5ff2dc795a4679893988f AS builder

ARG DEBIAN_FRONTEND=noninteractive

RUN \
    sudo --preserve-env apt-get update && \
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
    checkinstall --install=no --default --nodoc

FROM debian:sid-slim@sha256:21755f788723d30646e636ba8b7a3788991c8e917257810b12b0d2ea29daa543

LABEL maintainer="florian.stosse@gmail.com"
LABEL lastupdate="2025-06-29"
LABEL author="Florian Stosse"
LABEL description="ADMX linter, built with CMake 4.0.2 base image"
LABEL license="MIT license"

ARG DEBIAN_FRONTEND=noninteractive

RUN \
    apt-get update && \
    apt-get dist-upgrade -y && \
    apt-get install -y --no-install-recommends libxerces-c3.2 xsdcxx libboost-program-options1.83.0 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

COPY --from=builder /home/appuser/admx-lint/build/*.deb /

RUN \
    dpkg -i /*.deb && \
    ldconfig && \
    rm /*.deb