# syntax = docker/dockerfile:experimental
FROM --platform=linux/arm/v5 debian:trixie-backports

ARG PYTHON_VERSION

RUN apt update && DEBIAN_FRONTEND=noninteractive && apt install -y -t trixie-backports \
    curl wget unzip jq rustc build-essential cmake autoconf pkg-config \
    git bluez libffi-dev libssl-dev \
    libjpeg-dev zlib1g-dev libopenjp2-7 libtiff6 libturbojpeg0-dev tzdata \
    libudev-dev libpcap-dev libyaml-dev libxml2 libxslt-dev automake doxygen \
    graphviz imagemagick libasound2-dev libass-dev libavcodec-dev libavdevice-dev \
    libavfilter-dev libavformat-dev libavutil-dev libfreetype6-dev libgmp-dev \
    libmp3lame-dev libopencore-amrnb-dev libopencore-amrwb-dev libopus-dev librtmp-dev \
    libsdl2-dev libsdl2-image-dev libsdl2-mixer-dev libsdl2-net-dev libsdl2-ttf-dev \
    libsnappy-dev libsoxr-dev libssh-dev libtool libv4l-dev libva-dev libvdpau-dev \
    libvo-amrwbenc-dev libvorbis-dev libwebp-dev libx264-dev libx265-dev libxcb-shape0-dev \
    libxcb-shm0-dev libxcb-xfixes0-dev libxcb1-dev libxml2-dev nasm texinfo \
    # python build deps
    libssl-dev libffi-dev zlib1g-dev libbz2-dev liblzma-dev libsqlite3-dev libmpdec-dev \
    libreadline-dev libncurses-dev libnsl-dev libexpat1-dev media-types netbase tzdata libbluetooth-dev \
    #
    yasm libdrm-dev ca-certificates --no-install-recommends && apt clean && apt autoclean

ENV CC=arm-linux-gnueabi-gcc
ENV CXX=arm-linux-gnueabi-g++

RUN mkdir build-temp && \
    cd build-temp && \
    wget https://www.python.org/ftp/python/$PYTHON_VERSION/Python-$PYTHON_VERSION.tar.xz && \
    tar -xvf Python-$PYTHON_VERSION.tar.xz && \
    cd Python-$PYTHON_VERSION && \
    ./configure --enable-optimizations --with-lto --with-ensurepip=install && \
    make -j $(nproc) && \
    make install && \
    ln -sf /usr/local/bin/python3 /usr/local/bin/python && \
    ln -sf /usr/local/bin/pip3 /usr/local/bin/pip && \
    rm -rf /build-temp && \
    rm -rf /usr/local/lib/python*/test/* && \
    apt clean && \
    apt autoclean

RUN apt install -y -t trixie-backports meson ffmpeg && apt clean && apt autoclean

RUN ldconfig && ffmpeg -version && python --version
