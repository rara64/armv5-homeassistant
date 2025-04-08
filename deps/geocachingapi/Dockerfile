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
RUN find . -maxdepth 1 -name "*.whl" -exec pip install {} \;

# Install cargo
COPY $CARGO_DEB .
RUN dpkg -i *.deb

# Create wheels folder for maturin builds
RUN mkdir wheels

# Build patched geocachingapi
RUN git clone https://github.com/rara64/reverse_geocode --depth 1

RUN export PYKDTREE_VER=$(cat reverse_geocode/requirements.txt | awk -F'==' '/^pykdtree==/ {print $2}') && \
    wget -O pykdtree.tar.gz $(curl -sL https://pypi.org/pypi/pykdtree/$PYKDTREE_VER/json | jq -r '.urls[] | select(.packagetype == "sdist" and (.filename | endswith(".tar.gz"))) | .url') && \
    tar -xvzf pykdtree.tar.gz && \
    cd pykdtree-$PYKDTREE_VER && \
    sed -i "s/'numpy'//g" setup.py && \
    sed -E -i 's/"numpy>=[^"]*"[,\s]*//' pyproject.toml && \
    pip install . --find-links /

RUN cd reverse_geocode && \
    pip wheel --no-deps . -w ../wheels && \
    pip install . --find-links / && \
    python test_reverse_geocode.py

RUN pip install --find-links . geocachingapi==$WHEEL_VER