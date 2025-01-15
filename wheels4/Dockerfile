# syntax = docker/dockerfile:experimental
FROM --platform=linux/arm/v5 rara64/armv5-debian-base:latest
ARG UV_VER

#RUN apt update && DEBIAN_FRONTEND=noninteractive && apt install -y curl wget jq
RUN wget $(curl --silent https://api.github.com/repos/rara64/armv5te-cargo/releases/latest | jq -r '.assets[0].browser_download_url')
#RUN apt install -y build-essential cmake rustc python3.12 python3.12-venv python3.12-dev autoconf libssl-dev pkg-config unzip
RUN dpkg -i *.deb

RUN python3.12 -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

RUN wget -O uv.zip https://github.com/astral-sh/uv/archive/refs/tags/$UV_VER.zip
RUN unzip uv.zip && \
    mv uv-$UV_VER uv && \
    rm uv.zip 

# Replace atomic64 with atomic32 inside boxcar crate
RUN wget -O boxcar.zip https://github.com/ibraheemdev/boxcar/archive/refs/tags/v$(grep -oP 'boxcar = { version = "\K[^"]+' uv/Cargo.toml).zip
RUN unzip boxcar.zip && \
    mv boxcar-$(grep -oP 'boxcar = { version = "\K[^"]+' uv/Cargo.toml) boxcar && \
    rm boxcar.zip
RUN cd boxcar && \
    sed -i 's/AtomicU64/AtomicU32/g' src/raw.rs

# Build & install maturin wheel
#RUN pip install -v maturin
RUN mkdir /wheels
RUN git clone --depth 1 https://github.com/PyO3/maturin.git /maturin
RUN cd /maturin && cargo build --release && mv /maturin/target/release/maturin /usr/local/bin/maturin
#RUN WHEEL_PATH=$(find /root/.cache/pip/wheels -type f -name "*.whl" | grep -i "maturin") && mv "$WHEEL_PATH" /wheels/

# Patch & build uv wheel
RUN cd uv && sed -i "/boxcar\s*=/c\boxcar = { path = \"../boxcar\" }" Cargo.toml
RUN cd uv && sed -i "/\[profile.release\]/,/^\[/ s/lto\s*=.*/lto = \"off\"/" Cargo.toml
RUN cd uv && RUSTFLAGS="-C opt-level=0 -C linker=arm-linux-gnueabi-gcc" maturin build --release --strip --profile release --target armv5te-unknown-linux-gnueabi --manylinux off -o /wheels
