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

# Build av

#RUN pip install --find-links . av==$WHEEL_VER --no-binary av

# av 17.0.1 & 17.1.0 build workaround
RUN if [ "$WHEEL_VER" =  "17.0.1" ] || [ "$WHEEL_VER" =  "17.1.0" ]; then \
        wget $(curl -s https://pypi.org/pypi/av/$WHEEL_VER/json | jq -r '.urls[] | select (.packagetype == "sdist") | .url') \
        && curl -s https://pypi.org/pypi/av/$WHEEL_VER/json | jq -r '.urls[] | select (.packagetype == "sdist") | "\(.md5_digest) \(.filename)"' | md5sum -c - \
        && tar -xzf av-$WHEEL_VER.tar.gz \
        && sed -i 's/seek_func: seek_func_t = pyio_seek/seek_func = pyio_seek/' av-$WHEEL_VER/av/container/pyio.py \
        && sed -i 's/opaque_container: OpaqueContainer = OpaqueContainer()/opaque_container = OpaqueContainer()/' av-$WHEEL_VER/av/opaque.py \
        && pip install ./av-$WHEEL_VER \
        && rm -rf av-$WHEEL_VER; \
    else \
        pip install --find-links . av==$WHEEL_VER --no-binary av; \
    fi
