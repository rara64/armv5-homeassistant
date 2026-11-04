# syntax = docker/dockerfile:experimental
FROM --platform=linux/arm/v5 rara64/armv5-debian-base:latest
ARG MATURIN_WHL
ARG WHEEL_VER
ARG NUMPY_WHL
ARG ANTHROPIC_WHL
ARG HASS_TAG

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

# Clone lexiforest/curl_cffi and resolve possible cffi conflict
RUN CFFI_VER=$(curl -s https://raw.githubusercontent.com/home-assistant/core/${HASS_TAG}/homeassistant/package_constraints.txt | grep -oP '^cffi==\K[^\s#]+' || true) && \
    LATEST_TAG=$(curl -s https://api.github.com/repos/lexiforest/curl_cffi/releases/latest | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/') && \
    git clone -b ${LATEST_TAG} https://github.com/lexiforest/curl_cffi && \
    cd curl_cffi && \
    sed -i "s/{arch\['arch'\]}/arm-linux/g" scripts/build.py && \
    sed -i 's/{sysname}/gnueabi/g' scripts/build.py && \
    sed -i 's/__version__ = "2.3.1"/__version__ = "2.3.2"/g' scripts/build.py && \
    if [ -n "${CFFI_VER}" ]; then \
        sed -i -E "s/\"cffi[^\"]*\"/\"cffi==${CFFI_VER}\"/" pyproject.toml
    fi; \
    pip wheel --wheel-dir=../wheels --find-links ../ .

# Clone pywaze
RUN git clone -b v${WHEEL_VER} https://github.com/eifinger/pywaze && \
    cd pywaze && \
    sed -i "s/1.0+versionplaceholder.1/${WHEEL_VER}/g" pyproject.toml && \
    pip wheel --wheel-dir=../wheels --find-links ../wheels .