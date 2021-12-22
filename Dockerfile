FROM ubuntu:focal

LABEL maintainer="Arnaud Becheler" \
      description="Having quetzal-EGGS and quetzal-CRUMBS work on OSG with Singularity" \
      version="0.0.1"

ARG DEBIAN_FRONTEND=noninteractive

########## QUETZAL-EGGS 
RUN apt-get update -y
RUN apt-get install -y --no-install-recommends\
                    git \
                    gcc-9 \
                    g++ \
                    build-essential \
                    libboost-all-dev \
                    cmake \
                    unzip \
                    tar \
                    ca-certificates

# Install GDAL dependencies
RUN apt-get install -y libgdal-dev g++ --no-install-recommends && \
    apt-get clean -y
    
# Update C env vars so compiler can find gdal - once EGGS compiled we don't care anymore if singularity finds it or not
ENV CPLUS_INCLUDE_PATH=/usr/include/gdal
ENV C_INCLUDE_PATH=/usr/include/gdal

# Install Quetzal-EGGS
RUN git clone --recurse-submodules https://github.com/Becheler/quetzal-EGGS \
&& cd quetzal-EGGS \
&&  mkdir Release \
&&  cd Release \
&& cmake .. -DCMAKE_INSTALL_PREFIX="/usr/local/quetzal-EGGS" \
&& cmake --build . --config Release --target install

########## QUETZAL-CRUMBS
RUN set -xe \
    apt-get update && apt-get install -y \
    python3-pip \
    --no-install-recommends

RUN pip3 install --upgrade pip
RUN pip3 install numpy
RUN pip3 install GDAL==$(gdal-config --version) pyvolve==1.0.3 quetzal-crumbs==0.0.14

# Clean to make image smaller
RUN apt-get autoclean && \
    apt-get autoremove && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
