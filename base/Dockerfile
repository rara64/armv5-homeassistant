# syntax = docker/dockerfile:experimental
FROM --platform=linux/arm/v5 debian:trixie as builder

# Setup environment for Rust, ffmpeg, HASS and HASS components

RUN apt update && DEBIAN_FRONTEND=noninteractive && apt install -y \
    curl wget unzip jq rustc build-essential cmake autoconf pkg-config \
    python3.12 python3.12-venv python3.12-dev git bluez libffi-dev libssl-dev \
    libjpeg-dev zlib1g-dev libopenjp2-7 libtiff6 libturbojpeg0-dev tzdata \
    libudev-dev libpcap-dev libyaml-dev libxml2 libxslt-dev automake doxygen \
    graphviz imagemagick libasound2-dev libass-dev libavcodec-dev libavdevice-dev \
    libavfilter-dev libavformat-dev libavutil-dev libfreetype6-dev libgmp-dev \
    libmp3lame-dev libopencore-amrnb-dev libopencore-amrwb-dev libopus-dev librtmp-dev \
    libsdl2-dev libsdl2-image-dev libsdl2-mixer-dev libsdl2-net-dev libsdl2-ttf-dev \
    libsnappy-dev libsoxr-dev libssh-dev libtool libv4l-dev libva-dev libvdpau-dev \
    libvo-amrwbenc-dev libvorbis-dev libwebp-dev libx264-dev libx265-dev libxcb-shape0-dev \
    libxcb-shm0-dev libxcb-xfixes0-dev libxcb1-dev libxml2-dev lzma-dev meson nasm texinfo \
    yasm libdrm-dev python3-dev python3-pip --no-install-recommends && apt clean && apt autoclean

RUN mkdir ~/ffmpeg-libraries

RUN git clone --depth 1 https://github.com/mstorsjo/fdk-aac.git ~/ffmpeg-libraries/fdk-aac \
  && cd ~/ffmpeg-libraries/fdk-aac \
  && autoreconf -fiv \
  && ./configure \
  && make -j$(nproc) \
  && make install

RUN git clone --depth 1 https://code.videolan.org/videolan/dav1d.git ~/ffmpeg-libraries/dav1d \
  && mkdir ~/ffmpeg-libraries/dav1d/build \
  && cd ~/ffmpeg-libraries/dav1d/build \
  && meson .. \
  && ninja \
  && ninja install

RUN git clone --depth 1 https://github.com/ultravideo/kvazaar.git ~/ffmpeg-libraries/kvazaar \
  && cd ~/ffmpeg-libraries/kvazaar \
  && ./autogen.sh \
  && ./configure \
  && make -j$(nproc) \
  && make install

RUN git clone --depth 1 https://chromium.googlesource.com/webm/libvpx ~/ffmpeg-libraries/libvpx \
  && cd ~/ffmpeg-libraries/libvpx \
  && ./configure --disable-examples --disable-tools --disable-unit_tests --disable-docs \
  && make -j$(nproc) \
  && make install

RUN git clone --depth 1 https://aomedia.googlesource.com/aom ~/ffmpeg-libraries/aom \
  && mkdir ~/ffmpeg-libraries/aom/aom_build \
  && cd ~/ffmpeg-libraries/aom/aom_build \
  && cmake -G "Unix Makefiles" AOM_SRC \
       -DENABLE_NASM=off \
       -DENABLE_NEON=off \
       -DPYTHON_EXECUTABLE="$(which python3)" \
       -DCMAKE_C_FLAGS="-mfloat-abi=soft" \
       -DCMAKE_CXX_FLAGS="-mfloat-abi=soft" .. \
  && make -j$(nproc) \
  && make install

RUN git clone -b release-3.0.4 https://github.com/sekrit-twc/zimg.git ~/ffmpeg-libraries/zimg \
  && cd ~/ffmpeg-libraries/zimg \
  && sh autogen.sh \
  && ./configure --disable-simd \
       CFLAGS="-mfloat-abi=soft -march=armv5te" \
       CXXFLAGS="-mfloat-abi=soft" \
  && make -j$(nproc) \
  && make install

RUN ldconfig

RUN git clone --branch release/5.1 --depth 1 https://github.com/FFmpeg/FFmpeg.git ~/FFmpeg \
  && cd ~/FFmpeg \
  && ./configure \
    --extra-cflags="-I/usr/local/include -mfloat-abi=soft -Wincompatible-pointer-types -Wno-incompatible-pointer-types" \
    --extra-ldflags="-L/usr/local/lib" \
    --extra-libs="-lpthread -lm -latomic" \
    --arch=armel \
    --enable-gmp \
    --enable-gpl \
    --enable-libaom \
    --enable-libass \
    --enable-libdav1d \
    --enable-libdrm \
    --enable-libfdk-aac \
    --enable-libfreetype \
    --enable-libkvazaar \
    --enable-libmp3lame \
    --enable-libopencore-amrnb \
    --enable-libopencore-amrwb \
    --enable-libopus \
    --enable-librtmp \
    --enable-libsnappy \
    --enable-libsoxr \
    --enable-libssh \
    --enable-libvorbis \
    --enable-libvpx \
    --enable-libzimg \
    --enable-libwebp \
    --enable-libx264 \
    --enable-libx265 \
    --enable-libxml2 \
    --enable-nonfree \
    --enable-version3 \
    --target-os=linux \
    --enable-pthreads \
    --enable-openssl \
    --enable-hardcoded-tables \
    --disable-neon \
    --disable-vfp \
    --disable-static \
    --enable-shared \
    --disable-doc \
  && make -j$(nproc) \
  && make install

FROM --platform=linux/arm/v5 debian:trixie as base

COPY --from=builder /usr/local/bin /usr/local/bin
COPY --from=builder /usr/local/lib /usr/local/lib

RUN ldconfig
