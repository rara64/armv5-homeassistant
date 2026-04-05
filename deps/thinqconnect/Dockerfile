# syntax = docker/dockerfile:experimental
FROM --platform=linux/arm/v5 rara64/armv5-debian-base:latest
ARG MATURIN_WHL
ARG WHEEL_VER
ARG NUMPY_WHL
ARG ANTHROPIC_WHL
ARG CRYPTOGRAPHY_WHL

ENV CARGO_NET_GIT_FETCH_WITH_CLI="true"
ENV CARGO_TERM_PROGRESS_WHEN="never"

# Setup Python VENV
RUN python -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

# Install maturin & other wheels
COPY $MATURIN_WHL .
COPY $NUMPY_WHL .
COPY $ANTHROPIC_WHL .
COPY $CRYPTOGRAPHY_WHL .
RUN find . -maxdepth 1 -name "*.whl" -exec pip install {} \;

# Install rustc & cargo
COPY ./*.deb .
RUN dpkg -i rust-std*.deb \
    && dpkg -i rustc-dev*.deb \
    && dpkg -i rustc*.deb \
    && dpkg -i cargo*.deb

# Create wheels folder for maturin builds
RUN mkdir wheels

# Build thinqconnect
RUN pip install --find-links . thinqconnect==$WHEEL_VER
