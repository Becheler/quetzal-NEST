FROM ubuntu:focal

LABEL maintainer="Arnaud Becheler" \
      description="Having quetzal-CoalTL, quetzal-EGGS and quetzal-CRUMBS work, compatible with Open Science Grid with Singularity" \
      version="0.0.1"

ARG DEBIAN_FRONTEND=noninteractive

### QUETZAL-EGGS

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
                    graphviz
                    
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

### QUETZAL-CRUMBS

RUN set -xe \
    apt-get update && apt-get install -y \
    python3-pip \
    --no-install-recommends

RUN pip3 install --upgrade pip

# for crumbs ackage publishing
RUN pip3 install build twine pipenv numpy

# for crumbs geospatial
RUN pip3 install rasterio && \
    pip3 install matplotlib && \
    pip3 install imageio && \
    pip3 install imageio-ffmpeg && \
    pip3 install pyproj && \
    pip3 install shapely && \
    pip3 install fiona

# For crumbs.get_chelsa and crumbs.sdm
RUN pip3 install git+https://github.com/perrygeo/pyimpute.git@1371e5bf1f5ef35bd88ea5c2d57d2cbedf4f5d1d && \
    pip3 install xgboost && \
    pip3 install lightgbm && \
    pip3 install scikit-learn && \
    pip3 install geopandas
    
# crumbs.get_gbif weird dependencies
RUN pip3 install appdirs && \
    pip3 install geojson_rewind && \
    pip3 install geomet && \
    pip3 install requests_cache && \
    pip3 install git+https://github.com/sckott/pygbif.git#egg=pygbif
    
## Visualizations with crumbs and MAYAVI

# PyVirtualDisplay and its dependencies 
RUN pip3 install pyvirtualdisplay pillow EasyProcess
# install all dependencies and backends on Ubuntu 20.04:
RUN apt-get update -y && apt-get install -y \
    xvfb \
    xserver-xephyr \
    tigervnc-standalone-server \
    x11-utils \
    gnumeric \
    && apt-get clean -y
    
# Qt platform plugin xcb for mayavi
RUN apt-get update -y && apt-get install -y \
    xvfb \
    libxkbcommon-x11-0 \
    libxcb-icccm4 \
    libxcb-image0 \
    libxcb-keysyms1 \
    libxcb-randr0 \
    libxcb-render-util0 \
    libxcb-xinerama0 \
    && apt-get clean -y
    
# Solving a mysterious xcfb error
RUN apt-get update -y && apt-get install -y \
    qt5-default \
    && apt-get clean -y

# avoid _XSERVTransmkdir: ERROR: euid != 0,directory /tmp/.X11-unix will not be created.
RUN mkdir /tmp/.X11-unix && \
	chmod 1777 /tmp/.X11-unix && \
	chown root /tmp/.X11-unix/
# probably not required during image build
RUN Xvfb :99 &
ENV DISPLAY :99

# avoid matplotlib warning
ENV MPLCONFIGDIR="/tmp"

# avoid QStandardPaths: XDG_RUNTIME_DIR not set, defaulting to '/tmp/runtime-'
ENV XDG_RUNTIME_DIR="/tmp/runtime-"

# The Visualization Toolkit
RUN python3 -m pip install vtk

# Tool for image processing
RUN apt-get update && apt-get install -y \
    python3-opencv \
    && apt-get clean -y
    
RUN pip3 install opencv-python
RUN pip3 install PyVirtualDisplay
RUN pip3 install mayavi PyQt5
  
RUN pip3 install GDAL==$(gdal-config --version) pyvolve==1.0.3 quetzal-crumbs==1.0.10

# Clean to make image smaller
RUN apt-get autoclean && \
    apt-get autoremove && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
