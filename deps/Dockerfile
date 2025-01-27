# syntax = docker/dockerfile:experimental
FROM --platform=linux/arm/v5 rara64/armv5-debian-base:latest

ARG CRYPTOGRAPHY_VER
ARG NUMPY_VER
ARG PANDAS_VER
ARG UV_VER
ARG AV_VER

ENV CARGO_NET_GIT_FETCH_WITH_CLI="true"
ENV CARGO_TERM_PROGRESS_WHEN="never"
ENV CARGO_BUILD_JOBS=2
ENV RUSTFLAGS="-C codegen-units=1"

# Install latest cargo from rara64/armv5te-cargo repo
RUN wget $(curl --silent https://api.github.com/repos/rara64/armv5te-cargo/releases/latest | jq -r '.assets[0].browser_download_url')
RUN dpkg -i *.deb

# Setup Python VENV
RUN python -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"
RUN pip install wheel

# Build & install maturin wheel
RUN pip install maturin

# Build cryptography with no blas
RUN pip install \
    cryptography==$CRYPTOGRAPHY_VER \
    --config-settings=setup-args="-Dallow-noblas=true"

# Compile AV against ffmpeg binary included in the base image
RUN pip install av==$AV_VER --no-binary av

# Build numpy with no blas
RUN pip install numpy==$NUMPY_VER \
    --config-settings=setup-args="-Dallow-noblas=true"

# Build pandas
RUN pip install pandas==$PANDAS_VER --no-deps 

# Build latest uv
RUN --security=insecure mkdir -p /root/.cargo && chmod 777 /root/.cargo && mount -t tmpfs none /root/.cargo && RUSTFLAGS="-C opt-level=0 -C linker=arm-linux-gnueabi-gcc" pip install uv==$UV_VER
