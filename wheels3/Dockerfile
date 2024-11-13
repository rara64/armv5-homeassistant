# syntax = docker/dockerfile:experimental
FROM --platform=linux/arm/v5 debian:trixie

ARG ZEROCONF_VER
ARG ELEVENLABS_VER
ARG ANTHROPIC_VER
ARG MATURIN

RUN apt update && DEBIAN_FRONTEND=noninteractive && apt install -y curl wget jq
RUN wget $(curl --silent https://api.github.com/repos/rara64/armv5te-cargo/releases/latest | jq -r '.assets[0].browser_download_url')
RUN apt install -y build-essential cmake rustc python3.12 python3.12-venv python3.12-dev autoconf libssl-dev pkg-config unzip
RUN dpkg -i *.deb

RUN python3.12 -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

COPY $MATURIN .
RUN unzip wheels4.zip && pip install $(find . -type f -iname 'maturin*')

RUN --security=insecure mkdir -p /root/.cargo && chmod 777 /root/.cargo && mount -t tmpfs none /root/.cargo && pip install \
anthropic==$ANTHROPIC_VER \
elevenlabs==$ELEVENLABS_VER

RUN --security=insecure mkdir -p /root/.cargo && chmod 777 /root/.cargo && mount -t tmpfs none /root/.cargo && pip install \
zeroconf==$ZEROCONF_VER --no-deps

