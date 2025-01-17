# syntax = docker/dockerfile:experimental
FROM --platform=linux/arm/v5 rara64/armv5-debian-base:latest

ARG PANDAS_VER
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
RUN maturin --version

RUN pip install -v \
pynacl==$PYNACL_VER \
orjson==$ORJSON_VER --find-links .
