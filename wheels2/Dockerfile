# syntax = docker/dockerfile:experimental
FROM --platform=linux/arm/v5 rara64/armv5-debian-base:latest

ARG NUMPY_VER
ARG AV_VER
ARG PANDAS_VER
ARG MATURIN

RUN wget $(curl --silent https://api.github.com/repos/rara64/armv5te-cargo/releases/latest | jq -r '.assets[0].browser_download_url')
RUN dpkg -i *.deb

RUN python3.12 -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

COPY $MATURIN .
RUN unzip wheels4.zip && pip install $(find . -type f -iname 'maturin*')

ENV CARGO_NET_GIT_FETCH_WITH_CLI="true"

RUN pip install -v av==$AV_VER --no-binary av --find-links .

RUN pip install -v \
numpy==$NUMPY_VER --find-links .

RUN pip install -v \
pandas==$PANDAS_VER --find-links .

