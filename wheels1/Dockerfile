# syntax = docker/dockerfile:experimental
FROM --platform=linux/arm/v5 rara64/armv5-debian-base:latest

ARG CRYPTOGRAPHY_VER
ARG PYNACL_VER
ARG ORJSON_VER
ARG MATURIN

#RUN apt update && DEBIAN_FRONTEND=noninteractive && apt install -y curl wget jq
RUN wget $(curl --silent https://api.github.com/repos/rara64/armv5te-cargo/releases/latest | jq -r '.assets[0].browser_download_url')
#RUN apt install -y build-essential cmake rustc python3.12 python3.12-venv python3.12-dev autoconf unzip
RUN dpkg -i *.deb

RUN python3.12 -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

COPY $MATURIN .
RUN unzip wheels4.zip && pip install $(find . -type f -iname 'maturin*')

ENV CARGO_NET_GIT_FETCH_WITH_CLI="true"

# rustc wrapper for github actions - fixes freeze on compiling for some reason
RUN echo '#!/bin/bash' > /usr/local/bin/rustc_wrapper.sh && \
    echo '' >> /usr/local/bin/rustc_wrapper.sh && \
    echo 'exec stdbuf -oL -eL /usr/bin/rustc_real "$@"' >> /usr/local/bin/rustc_wrapper.sh && \
    chmod +x /usr/local/bin/rustc_wrapper.sh && \
    mv /usr/bin/rustc /usr/bin/rustc_real && \
    ln -s /usr/local/bin/rustc_wrapper.sh /usr/bin/rustc

RUN pip install -v \
cryptography==$CRYPTOGRAPHY_VER \
--config-settings=setup-args="-Dallow-noblas=true" \
--find-links .

RUN pip install -v \
pynacl==$PYNACL_VER \
orjson==$ORJSON_VER --find-links .
