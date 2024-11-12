# syntax = docker/dockerfile:experimental
FROM --platform=linux/arm/v5 debian:trixie

ARG PANDAS_VER
ARG PYNACL_VER
ARG ORJSON_VER
ARG MATURIN

RUN apt update && DEBIAN_FRONTEND=noninteractive && apt install -y curl wget jq
RUN wget $(curl --silent https://api.github.com/repos/rara64/armv5te-cargo/releases/latest | jq -r '.assets[0].browser_download_url')
RUN apt install -y build-essential cmake rustc python3.12 python3.12-venv python3.12-dev autoconf unzip
RUN dpkg -i *.deb

RUN python3.12 -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

COPY $MATURIN .
RUN unzip uv.zip && pip install $(find /uv -type f -iname 'maturin*')

RUN --security=insecure mkdir -p /root/.cargo && chmod 777 /root/.cargo && mount -t tmpfs none /root/.cargo && pip install \
pynacl==$PYNACL_VER \
orjson==$ORJSON_VER --no-deps \
pandas==$PANDAS_VER --no-deps
