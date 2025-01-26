# syntax = docker/dockerfile:experimental
FROM --platform=linux/arm/v5 debian:trixie

RUN apt update && DEBIAN_FRONTEND=noninteractive && apt install -y \
    curl wget unzip jq rustc build-essential cmake autoconf pkg-config \
    python3.13-full python3.13-dev git bluez libffi-dev libssl-dev \
    libjpeg-dev zlib1g-dev libopenjp2-7 libtiff6 libturbojpeg0-dev tzdata \
    libudev-dev libpcap-dev libyaml-dev libxml2 libxslt-dev automake doxygen \
    graphviz imagemagick libasound2-dev libass-dev libavcodec-dev libavdevice-dev \
    libavfilter-dev libavformat-dev libavutil-dev libfreetype6-dev libgmp-dev \
    libmp3lame-dev libopencore-amrnb-dev libopencore-amrwb-dev libopus-dev librtmp-dev \
    libsdl2-dev libsdl2-image-dev libsdl2-mixer-dev libsdl2-net-dev libsdl2-ttf-dev \
    libsnappy-dev libsoxr-dev libssh-dev libtool libv4l-dev libva-dev libvdpau-dev \
    libvo-amrwbenc-dev libvorbis-dev libwebp-dev libx264-dev libx265-dev libxcb-shape0-dev \
    libxcb-shm0-dev libxcb-xfixes0-dev libxcb1-dev libxml2-dev meson nasm texinfo \
    yasm libdrm-dev python3 --no-install-recommends && apt clean && apt autoclean

RUN apt install -y ffmpeg python-is-python3

RUN ldconfig && ffmpeg -version && python --version
