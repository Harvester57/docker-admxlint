# Cf. https://hub.docker.com/r/fstossesds/cmake
FROM fstossesds/cmake:latest

LABEL maintainer "florian.stosse@safrangroup.com"
LABEL lastupdate "05-15-2021"
LABEL author "Florian Stosse"
LABEL description "ADMX linter, built with CMake 3.22.0 base image"
LABEL license "MIT license"

RUN \
    apt-get update && \
    apt-get install -y --no-install-recommends libxerces-c-dev libboost-dev xsdcxx git

RUN git clone --depth 1 https://github.com/Harvester57/admx-lint.git

WORKDIR /admx-lint

RUN \
    mkdir build && \
    cd build && \
    cmake .. && \
    make -j2 && \
    make install

RUN \
    apt-get purge libxerces-c-dev libboost-dev xsdcxx git && \
    apt-get autoremove -y --purge && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
