# syntax = docker/dockerfile:experimental
FROM --platform=linux/arm/v5 rara64/armv5-debian-base:latest

ARG CRYPTOGRAPHY_VER
ARG NUMPY_VER
ARG PANDAS_VER
ARG UV_VER
ARG AV_VER
ARG MATURIN

ENV CARGO_NET_GIT_FETCH_WITH_CLI="true"
ENV CARGO_TERM_PROGRESS_WHEN="never"
ENV CARGO_BUILD_JOBS=2
ENV RUSTFLAGS="-C codegen-units=1"

RUN uname -m

# Install latest cargo from rara64/armv5te-cargo repo
RUN wget $(curl --silent https://api.github.com/repos/rara64/armv5te-cargo/releases/latest | jq -r '.assets[0].browser_download_url')
RUN dpkg -i *.deb

# Setup Python VENV
RUN python -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"
RUN pip install wheel

# Install maturin wheel
COPY $MATURIN .
RUN pip install $(find . -name "maturin*.whl" -print -quit)

# Build cryptography with no blas
RUN pip install \
    cryptography==$CRYPTOGRAPHY_VER \
    --config-settings=setup-args="-Dallow-noblas=true"

# Compile AV against ffmpeg binary included in the base image
RUN pip install av==$AV_VER --no-binary av

# Build numpy with no blas
RUN pip install numpy==$NUMPY_VER \
    --config-settings=setup-args="-Dallow-noblas=true"

# Build pandas
RUN pip install pandas==$PANDAS_VER --no-deps 

# Replace atomic64 with atomic32 inside boxcar crate - UV patch to support armv5
RUN wget -O uv.zip https://github.com/astral-sh/uv/archive/refs/tags/$UV_VER.zip && \
    unzip uv.zip && \
    mv uv-$UV_VER uv && \
    rm uv.zip 
RUN wget -O boxcar.zip https://github.com/ibraheemdev/boxcar/archive/refs/tags/v$(grep -oP 'boxcar = { version = "\K[^"]+' uv/Cargo.toml).zip
RUN unzip boxcar.zip && \
    mv boxcar-$(grep -oP 'boxcar = { version = "\K[^"]+' uv/Cargo.toml) boxcar && \
    rm boxcar.zip
RUN cd boxcar && \
    sed -i 's/AtomicU64/AtomicU32/g' src/raw.rs

# Patch & build uv wheel
RUN mkdir wheels && cd uv && \
    sed -i "/boxcar\s*=/c\boxcar = { path = \"../boxcar\" }" Cargo.toml && \
    sed -i "/\[profile.release\]/,/^\[/ s/lto\s*=.*/lto = false/" Cargo.toml
RUN --security=insecure mkdir -p /root/.cargo && chmod 777 /root/.cargo && mount -t tmpfs none /root/.cargo && cd uv && RUSTFLAGS="-C opt-level=0 -C linker=arm-linux-gnueabi-gcc" maturin build --release --strip --profile release --target armv5te-unknown-linux-gnueabi --manylinux off -o /wheels
RUN find /wheels -type f -iname '*.whl' -exec pip install {} \;
