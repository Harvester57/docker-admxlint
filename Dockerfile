# Cf. https://hub.docker.com/r/fstossesds/cmake
FROM fstossesds/cmake:latest@sha256:45e168368a9550175ab3223021a2433547eeabdd19f6e76cda62d98aaa9252d0 AS builder

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
    checkinstall --install=no --default

FROM debian:sid-slim@sha256:ce77de9639fc8f48decaa4d94fa5ed1a78e5b7356822f105d18d79d5b2b54772

LABEL maintainer="florian.stosse@gmail.com"
LABEL lastupdate="2025-05-29"
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
    ldconfig

RUN rm /*.deb