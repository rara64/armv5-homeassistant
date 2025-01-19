# syntax = docker/dockerfile:experimental
FROM --platform=linux/arm/v5 rara64/armv5-debian-base:latest

ARG ZEROCONF_VER
ARG ELEVENLABS_VER
ARG ANTHROPIC_VER
ARG MATURIN

RUN wget $(curl --silent https://api.github.com/repos/rara64/armv5te-cargo/releases/latest | jq -r '.assets[0].browser_download_url')
RUN dpkg -i *.deb

RUN python3.12 -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"
   
COPY $MATURIN .
RUN unzip wheels4.zip && pip install $(find . -type f -iname 'maturin*')

# rustc wrapper for github actions - fixes freeze on compiling for some reason
RUN echo '#!/bin/bash' > /usr/local/bin/rustc_wrapper.sh && \
    echo '' >> /usr/local/bin/rustc_wrapper.sh && \
    echo 'if echo "$@" | grep -i "extra-filename"; then' >> /usr/local/bin/rustc_wrapper.sh && \
    echo '  found=1' >> /usr/local/bin/rustc_wrapper.sh && \
    echo 'fi' >> /usr/local/bin/rustc_wrapper.sh && \
    echo 'if [ "$found" -eq 1 ]; then' >> /usr/local/bin/rustc_wrapper.sh && \
    echo '  echo "Sleeping for 2 seconds..."' >> /usr/local/bin/rustc_wrapper.sh && \
    echo '  echo "sleep 2"' >> /usr/local/bin/rustc_wrapper.sh && \
    echo 'fi' >> /usr/local/bin/rustc_wrapper.sh && \
    echo 'exec stdbuf -oL -eL /usr/bin/rustc_real "$@"' >> /usr/local/bin/rustc_wrapper.sh && \
    chmod +x /usr/local/bin/rustc_wrapper.sh && \
    mv /usr/bin/rustc /usr/bin/rustc_real && \
    ln -s /usr/local/bin/rustc_wrapper.sh /usr/bin/rustc

ENV CARGO_NET_GIT_FETCH_WITH_CLI="true"

RUN pip install -v elevenlabs==$ELEVENLABS_VER --find-links .

RUN pip install -v anthropic==$ANTHROPIC_VER --find-links .

RUN pip install -v zeroconf==$ZEROCONF_VER --find-links .

