FROM ubuntu:focal

LABEL maintainer="Arnaud Becheler" \
      description="Having quetzal-CoalTL, quetzal-EGGS and quetzal-CRUMBS work, compatible with Open Science Grid with Singularity" \
      version="0.0.1"

ARG DEBIAN_FRONTEND=noninteractive

########## QUETZAL-EGGS
RUN apt-get update -y
RUN apt-get install -y --no-install-recommends\
                    vim \
                    git \
                    gcc-9 \
                    g++ \
                    build-essential \
                    libboost-all-dev \
                    cmake \
                    unzip \
                    tar \
                    ca-certificates \
                    doxygen \
                    graphviz \
                    qt5-default

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
RUN pip3 install build twine pipenv numpy # for crumbs publishing
RUN pip3 install rasterio && \
    pip3 install matplotlib && \
    pip3 install imageio && \
    pip3 install imageio-ffmpeg && \
    pip3 install pyproj && \
    pip3 install shapely && \
    pip3 install fiona && \
    pip3 install scikit-learn && \ 
    pip3 install pyimpute && \ 
    pip3 install geopandas && \
    pip3 install pygbif && \ 
    pip3 install vtk && \
    pip3 install pyqt5 && \
    pip3 install libvtk6-dev
    
RUN pip3 install mayavi
    
  
RUN pip3 install GDAL==$(gdal-config --version) pyvolve==1.0.3 quetzal-crumbs==0.0.15

# Clean to make image smaller
RUN apt-get autoclean && \
    apt-get autoremove && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
