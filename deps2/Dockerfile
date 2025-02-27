# syntax = docker/dockerfile:experimental
FROM --platform=linux/arm/v5 rara64/armv5-debian-base:latest

ARG ORJSON_VER
ARG PYNACL_VER
ARG ZEROCONF_VER
ARG ANTHROPIC_VER
ARG DEEBOT_VER
ARG ELEVENLABS_VER
ARG MATRIX_VER
ARG DEPS
ARG MATURIN

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

# Install maturin
COPY $DEPS .
COPY $MATURIN .
RUN unzip -o -j deps.zip -d wheels && \
    find wheels/ -type f -name 'numpy*' -exec pip install {} \;
RUN pip install $(find . -name "maturin*.whl" -print -quit)

# Build matrix-nio
RUN pip install --find-links ./maturin matrix-nio==$MATRIX_VER

# Build anthropic
RUN pip install --find-links ./maturin anthropic==$ANTHROPIC_VER

# Build deebot-client
RUN pip install --find-links ./maturin deebot-client==$DEEBOT_VER

# Build elevenlabs
RUN pip install --find-links ./maturin elevenlabs==$ELEVENLABS_VER

# Build orjson
RUN pip install --find-links ./maturin orjson==$ORJSON_VER

# Build pynacl
RUN pip install --find-links ./maturin pynacl==$PYNACL_VER

# Build zeroconf
RUN pip install --find-links ./maturin zeroconf==$ZEROCONF_VER
