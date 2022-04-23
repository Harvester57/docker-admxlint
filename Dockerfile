# Cf. https://hub.docker.com/r/fstossesds/cmake
FROM fstossesds/cmake:latest

LABEL maintainer "florian.stosse@safrangroup.com"
LABEL lastupdate "2022-04-18"
LABEL author "Florian Stosse"
LABEL description "ADMX linter, built with CMake 3.23.1 base image"
LABEL license "MIT license"

RUN \
    sudo apt-get update && \
    sudo apt-get install -y --no-install-recommends libxerces-c-dev xsdcxx git libboost-program-options-dev

WORKDIR /home/appuser

RUN git clone --depth 1 https://github.com/Harvester57/admx-lint.git

WORKDIR /home/appuser/admx-lint

RUN \
    mkdir build && \
    cd build && \
    cmake .. && \
    make -j$(getconf _NPROCESSORS_ONLN) && \
    sudo make install
    
WORKDIR /

RUN \
    sudo apt-get purge -y xsdcxx git && \
    sudo apt-get autoremove -y --purge && \
    sudo apt-get clean && \
    sudo rm -rf /var/lib/apt/lists/* && \
    sudo rm -rf /home/appuser/admx-lint && \
    sudo deluser appuser sudo
