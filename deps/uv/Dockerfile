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

# Replace atomic64 with atomic32 inside boxcar crate - UV patch to support armv5
RUN wget -O uv.zip https://github.com/astral-sh/uv/archive/refs/tags/$WHEEL_VER.zip && \
    unzip uv.zip && \
    mv uv-$WHEEL_VER uv && \
    rm uv.zip 
RUN wget -O boxcar.zip https://github.com/ibraheemdev/boxcar/archive/refs/tags/v$(grep -oP 'boxcar = { version = "\K[^"]+' uv/Cargo.toml).zip
RUN unzip boxcar.zip && \
    mv boxcar-$(grep -oP 'boxcar = { version = "\K[^"]+' uv/Cargo.toml) boxcar && \
    rm boxcar.zip
RUN cd boxcar && \
    sed -i 's/AtomicU64/AtomicU32/g' src/raw.rs

# Patch & build uv wheel
RUN cd uv && \
    sed -i "/boxcar\s*=/c\boxcar = { path = \"../boxcar\" }" Cargo.toml && \
    sed -i "/\[profile.release\]/,/^\[/ s/lto\s*=.*/lto = false/" Cargo.toml
RUN --security=insecure mkdir -p /root/.cargo && chmod 777 /root/.cargo && mount -t tmpfs none /root/.cargo && cd uv && RUSTFLAGS="-C opt-level=0 -C linker=arm-linux-gnueabi-gcc" maturin build --release --strip --profile release --target armv5te-unknown-linux-gnueabi --manylinux off -o /wheels
RUN find /wheels -type f -iname '*.whl' -exec pip install {} \;