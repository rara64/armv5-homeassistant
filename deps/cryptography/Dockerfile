# syntax = docker/dockerfile:experimental
FROM --platform=linux/arm/v5 rara64/armv5-debian-base:latest
ARG CARGO_DEB
ARG MATURIN_WHL
ARG WHEEL_VER
ARG NUMPY_WHL
ARG ANTHROPIC_WHL

ENV CARGO_NET_GIT_FETCH_WITH_CLI="true"
ENV CARGO_TERM_PROGRESS_WHEN="never"

# Setup Python VENV
RUN python -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

# Install maturin & other wheels
COPY $MATURIN_WHL .
COPY $NUMPY_WHL .
COPY $ANTHROPIC_WHL .
RUN find . -name "*.whl" -print0 | while IFS= read -r -d $'\0' file; do pip install "$file"; done

# Install cargo
COPY $CARGO_DEB .
RUN dpkg -i *.deb

# Create wheels folder for maturin builds
RUN mkdir wheels

# Build cryptography
RUN pip install --find-links . \
    cryptography==$WHEEL_VER -v \
    --config-settings=setup-args="-Dallow-noblas=true"