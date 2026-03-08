# Cf. https://github.com/Harvester57/docker-cmake/pkgs/container/docker-cmake
ARG BUILDKIT_SBOM_SCAN_STAGE=true
FROM ghcr.io/harvester57/docker-cmake:latest@sha256:36e209ef70413518569aabae6861a49b5513a11401a1b2b2d56197180dee411f AS builder

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

FROM dhi.io/debian-base:trixie@sha256:0ad2d35710a1ac7607a15f45a59aeae2f9f048b13fb07240e732c99953473c77

LABEL maintainer="florian.stosse@gmail.com"
LABEL lastupdate="2026-03-08"
LABEL author="Florian Stosse"
LABEL description="ADMX linter, built with CMake 4.2.3 base image"
LABEL license="MIT license"

ARG DEBIAN_FRONTEND=noninteractive

COPY --from=builder /home/nonroot/admx-lint/build/*.deb /

USER root
RUN \
    apt-get update && \
    apt-get full-upgrade -y && \
    apt-get install -y --no-install-recommends libxerces-c3.2 xsdcxx libboost-program-options1.83.0 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    dpkg -i /*.deb && \
    ldconfig && \
    rm /*.deb

USER nonroot
