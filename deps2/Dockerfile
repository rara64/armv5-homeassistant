# syntax = docker/dockerfile:experimental
FROM --platform=linux/arm/v5 rara64/armv5-debian-base:latest

ARG ORJSON_VER
ARG PYNACL_VER
ARG ZEROCONF_VER
ARG DEPS

ENV CARGO_NET_GIT_FETCH_WITH_CLI="true"
ENV CARGO_TERM_PROGRESS_WHEN="never"
ENV CARGO_BUILD_JOBS=2
ENV RUSTFLAGS="-C codegen-units=1"

# Install latest cargo from rara64/armv5te-cargo repo
RUN wget $(curl --silent https://api.github.com/repos/rara64/armv5te-cargo/releases/latest | jq -r '.assets[0].browser_download_url')
RUN dpkg -i *.deb

# Setup Python VENV
RUN python3.12 -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"
RUN pip install wheel

# Install maturin
COPY $DEPS .
RUN unzip -o -j deps.zip -d wheels && \
    find wheels/ -type f -name 'maturin*' -exec pip install {} \;

# Build orjson
RUN pip install orjson==$ORJSON_VER

# Build pynacl
RUN pip install pynacl==$PYNACL_VER

# Build zeroconf
RUN pip install zeroconf==$ZEROCONF_VER
