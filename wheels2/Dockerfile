# syntax = docker/dockerfile:experimental
FROM --platform=linux/arm/v5 rara64/armv5-debian-base:latest

ARG NUMPY_VER
ARG CRYPTOGRAPHY_VER
ARG HAAV_VER
ARG MATURIN

RUN wget $(curl --silent https://api.github.com/repos/rara64/armv5te-cargo/releases/latest | jq -r '.assets[0].browser_download_url')
RUN dpkg -i *.deb

RUN python3.12 -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

COPY $MATURIN .
RUN unzip wheels4.zip && pip install $(find . -type f -iname 'maturin*')

RUN --security=insecure mkdir -p /root/.cargo && chmod 777 /root/.cargo && mount -t tmpfs none /root/.cargo && pip install \
numpy==$NUMPY_VER \
ha-av==$HAAV_VER \
cryptography==$CRYPTOGRAPHY_VER \
--config-settings=setup-args="-Dallow-noblas=true" --no-deps

