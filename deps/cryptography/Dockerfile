# syntax = docker/dockerfile:experimental
FROM --platform=linux/arm/v5 rara64/armv5-debian-base:latest
ARG CARGO
ARG MATURIN
ARG WHEEL_VER

# Setup Python VENV
RUN python -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

# Install maturin
COPY $MATURIN .
RUN MATURIN=$(find . -name "maturin*.whl" -print -quit) && pip install $MATURIN

# Install cargo
COPY $CARGO .
RUN dpkg -i *.deb

# Build cryptography
RUN pip install --find-links . \
    cryptography==$WHEEL_VER -v \
    --config-settings=setup-args="-Dallow-noblas=true"