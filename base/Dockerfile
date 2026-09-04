# syntax = docker/dockerfile:experimental
FROM --platform=linux/arm/v5 debian:trixie-backports

ARG PYTHON_VERSION

RUN apt update && apt install -y -t trixie-backports \
    curl wget unzip jq rustc build-essential cmake autoconf pkg-config \
    git bluez libffi-dev libssl-dev \
    libjpeg-dev zlib1g-dev libopenjp2-7 libtiff6 libturbojpeg0-dev tzdata \
    libudev-dev libpcap-dev libyaml-dev libxml2 libxslt-dev automake \
    imagemagick libfreetype6-dev libgmp-dev \
    libssh-dev libtool \
    libwebp-dev libxml2-dev \
    libbz2-dev liblzma-dev libsqlite3-dev libmpdec-dev \
    libreadline-dev libncurses-dev libnsl-dev libexpat1-dev media-types netbase libbluetooth-dev \
    ca-certificates meson ninja-build --no-install-recommends

RUN wget https://github.com/rara64/armv5-ffmpeg/releases/download/8.1.2/ffmpeg_8.1.2_armel_optimized.deb && \
    apt install -y --no-install-recommends ./ffmpeg_8.1.2_armel_optimized.deb && \
    rm ffmpeg_8.1.2_armel_optimized.deb

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

RUN apt clean && apt autoclean

RUN ldconfig && ffmpeg -version && python --version
