# syntax = docker/dockerfile:experimental
FROM --platform=linux/arm/v5 rara64/armv5-debian-base:latest
ARG CARGO_DEB
ARG MATURIN_WHL
ARG WHEEL_VER
ARG NUMPY_WHL

ENV CARGO_NET_GIT_FETCH_WITH_CLI="true"
ENV CARGO_TERM_PROGRESS_WHEN="never"

# Setup Python VENV
RUN python -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

# Install maturin
COPY $MATURIN_WHL .
RUN MATURIN=$(find . -name "maturin*.whl" -print -quit) && pip install $MATURIN

# Install numpy if available
COPY $NUMPY_WHL .
RUN NUMPY=$(find . -name "numpy*.whl" -print -quit) && \
    [ -n "$NUMPY" ] && pip install "$NUMPY" || echo "No numpy wheel found"

# Install cargo
COPY $CARGO_DEB .
RUN dpkg -i *.deb

# Create wheels folder for maturin builds
mkdir wheels

# Build deebot-client
RUN pip install --find-links . deebot-client==$WHEEL_VER