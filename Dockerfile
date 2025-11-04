# Cf. https://github.com/Harvester57/docker-cmake/pkgs/container/docker-cmake
FROM ghcr.io/harvester57/docker-cmake:latest@sha256:8e7aa6ba8e26b10bb9fa268b7c3b29d6b7b2c0d38b23bcf6f4b352b2d4ffc5c4 AS builder

ARG DEBIAN_FRONTEND=noninteractive

RUN \
    sudo --preserve-env apt-get update && \
    sudo --preserve-env apt-get full-upgrade -y && \
    sudo --preserve-env apt-get install -y --no-install-recommends libxerces-c-dev xsdcxx git libboost-program-options-dev checkinstall rev

USER appuser
WORKDIR /home/appuser

RUN git clone --depth 1 https://github.com/Harvester57/admx-lint.git

WORKDIR /home/appuser/admx-lint

RUN \
    mkdir build && \
    cd build && \
    cmake .. && \
    make -j$(getconf _NPROCESSORS_ONLN) && \
    checkinstall --install=no --default --nodoc --pkgversion="1.0"

FROM debian:sid-slim@sha256:f0920267adafa79cc5718eb036e76bf6214c63607fff7a8deeae3505e2635b80

LABEL maintainer="florian.stosse@gmail.com"
LABEL lastupdate="2025-06-29"
LABEL author="Florian Stosse"
LABEL description="ADMX linter, built with CMake 4.0.2 base image"
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

