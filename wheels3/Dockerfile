# syntax = docker/dockerfile:experimental
FROM --platform=linux/arm/v5 rara64/armv5-debian-base:latest

ARG ZEROCONF_VER
ARG ELEVENLABS_VER
ARG ANTHROPIC_VER
ARG MATURIN

#RUN apt update && DEBIAN_FRONTEND=noninteractive && apt install -y curl wget jq
RUN wget $(curl --silent https://api.github.com/repos/rara64/armv5te-cargo/releases/latest | jq -r '.assets[0].browser_download_url')
#RUN apt install -y build-essential cmake rustc python3.12 python3.12-venv python3.12-dev autoconf libssl-dev pkg-config unzip
RUN dpkg -i *.deb
#RUN apt update && apt install -y procps

RUN python3.12 -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

#RUN pip install --upgrade pip

   
COPY $MATURIN .
RUN unzip wheels4.zip && pip install $(find . -type f -iname 'maturin*')

RUN echo '#!/bin/bash' > /usr/local/bin/rustc_wrapper.sh && \
    echo '' >> /usr/local/bin/rustc_wrapper.sh && \
    echo 'if (for arg in "$@"; do echo "$arg" | grep -q "\.rs"; done); then' >> /usr/local/bin/rustc_wrapper.sh && \
    echo '  echo "========================================"' >> /usr/local/bin/rustc_wrapper.sh && \
    echo '  echo "Resource Usage Before rustc Execution:"' >> /usr/local/bin/rustc_wrapper.sh && \
    echo '  echo "Date/Time: $(date)"' >> /usr/local/bin/rustc_wrapper.sh && \
    echo '  echo "----------------------------------------"' >> /usr/local/bin/rustc_wrapper.sh && \
    echo '  echo "Memory Usage:"' >> /usr/local/bin/rustc_wrapper.sh && \
    echo '  free -h' >> /usr/local/bin/rustc_wrapper.sh && \
    echo '  echo "----------------------------------------"' >> /usr/local/bin/rustc_wrapper.sh && \
    echo '  echo "CPU Usage:"' >> /usr/local/bin/rustc_wrapper.sh && \
    echo '  top -b -n 1 | head -n 5' >> /usr/local/bin/rustc_wrapper.sh && \
    echo '  echo "----------------------------------------"' >> /usr/local/bin/rustc_wrapper.sh && \
    echo '  echo "Disk Usage:"' >> /usr/local/bin/rustc_wrapper.sh && \
    echo '  df -h' >> /usr/local/bin/rustc_wrapper.sh && \
    echo '  echo "----------------------------------------"' >> /usr/local/bin/rustc_wrapper.sh && \
    echo 'fi' >> /usr/local/bin/rustc_wrapper.sh && \
    echo '/usr/bin/rustc_real "$@"' >> /usr/local/bin/rustc_wrapper.sh && \
    chmod +x /usr/local/bin/rustc_wrapper.sh

# Rename the original rustc and replace it with the wrapper
RUN mv /usr/bin/rustc /usr/bin/rustc_real && \
    ln -s /usr/local/bin/rustc_wrapper.sh /usr/bin/rustc

ENV CARGO_NET_GIT_FETCH_WITH_CLI="true"

ENV RUST_BACKTRACE=1
ENV CARGO_TERM_VERBOSE=true
#ENV CARGO_LOG=debug
#ENV CARGO_BUILD_JOBS=2

RUN pip install -v elevenlabs==$ELEVENLABS_VER --find-links .

RUN pip install -v \
anthropic==$ANTHROPIC_VER --find-links .


RUN pip install -v zeroconf==$ZEROCONF_VER --find-links .

