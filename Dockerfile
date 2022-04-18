# Cf. https://hub.docker.com/r/fstossesds/cmake
FROM fstossesds/cmake:latest

LABEL maintainer "florian.stosse@safrangroup.com"
LABEL lastupdate "2022-04-18"
LABEL author "Florian Stosse"
LABEL description "ADMX linter, built with CMake 3.23.1 base image"
LABEL license "MIT license"

RUN \
    apt-get update && \
    apt-get install -y --no-install-recommends libxerces-c-dev xsdcxx git libboost-program-options-dev

RUN git clone --depth 1 https://github.com/Harvester57/admx-lint.git

WORKDIR /admx-lint

RUN \
    mkdir build && \
    cd build && \
    cmake .. && \
    make -j3 && \
    make install

RUN \
    apt-get purge -y xsdcxx git && \
    apt-get autoremove -y --purge && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
