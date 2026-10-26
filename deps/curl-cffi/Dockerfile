# syntax = docker/dockerfile:experimental
FROM --platform=linux/arm/v5 rara64/armv5-debian-base:latest
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

# Install rustc & cargo
COPY ./*.deb .
RUN dpkg -i rust-std*.deb \
    && dpkg -i rustc-dev*.deb \
    && dpkg -i rustc*.deb \
    && dpkg -i cargo*.deb

# Create wheels folder for maturin builds
RUN mkdir wheels

# Clone lexiforest/curl_cffi
RUN git clone -b v${WHEEL_VER} https://github.com/lexiforest/curl_cffi && \
    cd curl_cffi && \
    sed -i "s/{arch\['arch'\]}/arm-linux/g" scripts/build.py && \
    sed -i 's/{sysname}/gnueabi/g' scripts/build.py && \
    sed -i 's#lexiforest/curl-impersonate#rara64/curl-impersonate#g' scripts/build.py && \
    pip wheel --wheel-dir=../wheels --find-links ../ .
