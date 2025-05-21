# Cf. https://hub.docker.com/r/fstossesds/cmake
FROM fstossesds/cmake:latest@sha256:cf8c4a5de17ff2d9fb48e2e75b613be2528918e3b70fe9bd2938c9642f5713cb

LABEL maintainer="florian.stosse@gmail.com"
LABEL lastupdate="2025-04-27"
LABEL author="Florian Stosse"
LABEL description="ADMX linter, built with CMake 4.0.1 base image"
LABEL license="MIT license"

ARG DEBIAN_FRONTEND=noninteractive

RUN \
    sudo --preserve-env apt-get update && \
    sudo --preserve-env apt-get install -y --no-install-recommends libxerces-c-dev xsdcxx git libboost-program-options-dev

USER appuser
WORKDIR /home/appuser

RUN git clone --depth 1 https://github.com/Harvester57/admx-lint.git

WORKDIR /home/appuser/admx-lint

RUN \
    mkdir build && \
    cd build && \
    cmake .. && \
    make -j$(getconf _NPROCESSORS_ONLN) && \
    sudo --preserve-env make install
    
WORKDIR /

RUN \
    sudo --preserve-env apt-get purge -y xsdcxx git && \
    sudo --preserve-env apt-get autoremove -y --purge && \
    sudo --preserve-env apt-get clean && \
    sudo --preserve-env rm -rf /var/lib/apt/lists/* && \
    sudo --preserve-env rm -rf /home/appuser/admx-lint
