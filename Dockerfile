# Cf. https://hub.docker.com/r/fstossesds/cmake
FROM fstossesds/cmake:latest@sha256:5916293daeec488b70b15e2099611af1643705b5bd6c0d28d4db443b7099e155

LABEL maintainer="florian.stosse@gmail.com"
LABEL lastupdate="2025-05-29"
LABEL author="Florian Stosse"
LABEL description="ADMX linter, built with CMake 4.0.2 base image"
LABEL license="MIT license"

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
    checkinstall --install=no --default && \
    cp *.deb / && ls /
    
WORKDIR /

RUN \
    sudo --preserve-env apt-get purge -y xsdcxx git && \
    sudo --preserve-env apt-get autoremove -y --purge && \
    sudo --preserve-env apt-get clean && \
    sudo --preserve-env rm -rf /var/lib/apt/lists/* && \
    sudo --preserve-env rm -rf /home/appuser/admx-lint
