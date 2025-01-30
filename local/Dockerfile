# syntax = docker/dockerfile:experimental
FROM --platform=linux/amd64 debian:bullseye AS cargo-builder

# Install nightly toolchain for Rust
RUN apt update && DEBIAN_FRONTEND=noninteractive && apt install -y curl git ca-certificates --no-install-recommends
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs -o rustup.sh && chmod +x rustup.sh && ./rustup.sh -y --default-toolchain nightly
ENV PATH="/root/.cargo/bin:$PATH"

# Setup ARMV5TE cross-compilation environment
RUN rustup target add armv5te-unknown-linux-gnueabi --toolchain nightly
RUN dpkg --add-architecture armel
RUN apt update && DEBIAN_FRONTEND=noninteractive && apt install -y gcc-arm-linux-gnueabi pkg-config libc6-dev-armel-cross crossbuild-essential-armel
RUN echo '[target.armv5te-unknown-linux-gnueabi]\nlinker = "arm-linux-gnueabi-gcc"' >> /root/.cargo/config
RUN cargo install cargo-deb
ENV PKG_CONFIG_ALLOW_CROSS="true"
ENV PKG_CONFIG_PATH="/usr/lib/arm-linux-gnueabi/pkgconfig"

# Build latest Cargo
RUN git clone https://github.com/rust-lang/cargo
WORKDIR /cargo
RUN echo '\
[package.metadata.deb]\n\
maintainer = "rara"\n\
copyright = "MIT OR Apache-2.0"\n\
extended-description = """\n\
Cargo, a package manager for Rust.\n\
"""' >> Cargo.toml
RUN cargo deb --target armv5te-unknown-linux-gnueabi -- --features=vendored-openssl

FROM --platform=linux/arm/v5 golang:1.23 as go2rtc-builder

RUN export TAG=$(curl --silent https://api.github.com/repos/home-assistant/core/releases | jq -r 'map(select(.prerelease==false)) | first | .tag_name') && \
    export GO2RTC=$(curl -s https://raw.githubusercontent.com/home-assistant/core/refs/tags/$TAG/Dockerfile | grep -oP 'curl -L https://github.com/AlexxIT/go2rtc/releases/download/v\K[0-9.]+') && \
    git clone -b "v${GO2RTC}" https://github.com/AlexxIT/go2rtc/

RUN cd go2rtc && \
    export GOOS=linux && \
    export GOARCH=arm && \
    export GOARM=5 && \
    FILENAME="go2rtc_linux_armv5" go build -ldflags "-s -w" -trimpath -o $FILENAME && upx --lzma --force-overwrite -q --no-progress $FILENAME && \
    mv $FILENAME ../$FILENAME

FROM --platform=linux/arm/v5 debian:trixie as hass-builder

RUN apt update && DEBIAN_FRONTEND=noninteractive && apt install -y \
    curl wget unzip jq rustc build-essential cmake autoconf pkg-config \
    python3.13-full python3.13-dev git bluez libffi-dev libssl-dev \
    libjpeg-dev zlib1g-dev libopenjp2-7 libtiff6 libturbojpeg0-dev tzdata \
    libudev-dev libpcap-dev libyaml-dev libxml2 libxslt-dev automake doxygen \
    graphviz imagemagick libasound2-dev libass-dev libavcodec-dev libavdevice-dev \
    libavfilter-dev libavformat-dev libavutil-dev libfreetype6-dev libgmp-dev \
    libmp3lame-dev libopencore-amrnb-dev libopencore-amrwb-dev libopus-dev librtmp-dev \
    libsdl2-dev libsdl2-image-dev libsdl2-mixer-dev libsdl2-net-dev libsdl2-ttf-dev \
    libsnappy-dev libsoxr-dev libssh-dev libtool libv4l-dev libva-dev libvdpau-dev \
    libvo-amrwbenc-dev libvorbis-dev libwebp-dev libx264-dev libx265-dev libxcb-shape0-dev \
    libxcb-shm0-dev libxcb-xfixes0-dev libxcb1-dev libxml2-dev meson nasm texinfo \
    yasm libdrm-dev python3 --no-install-recommends && apt clean && apt autoclean

RUN apt install -y ffmpeg python-is-python3

# Install cargo
COPY --from=cargo-builder /cargo/target/armv5te-unknown-linux-gnueabi/debian/*.deb .
RUN dpkg -i *.deb

# Setup Python VENV
RUN python -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

ENV CARGO_NET_GIT_FETCH_WITH_CLI="true"
ENV CARGO_TERM_PROGRESS_WHEN="never"
ENV CARGO_BUILD_JOBS=2
ENV RUSTFLAGS="-C codegen-units=1"

RUN pip install wheel maturin

# Build UV for ARMV5TE
# Replace atomic64 with atomic32 inside boxcar crate - UV patch to support armv5
ENV UV_VER=$(curl -s https://pypi.org/pypi/uv/json | jq -r '.info.version')

RUN wget -O uv.zip https://github.com/astral-sh/uv/archive/refs/tags/$UV_VER.zip && \
    unzip uv.zip && \
    mv uv-$UV_VER uv && \
    rm uv.zip 

RUN wget -O boxcar.zip https://github.com/ibraheemdev/boxcar/archive/refs/tags/v$(grep -oP 'boxcar = { version = "\K[^"]+' uv/Cargo.toml).zip && \
    unzip boxcar.zip && \
    mv boxcar-$(grep -oP 'boxcar = { version = "\K[^"]+' uv/Cargo.toml) boxcar && \
    rm boxcar.zip && \
    cd boxcar && \
    sed -i 's/AtomicU64/AtomicU32/g' src/raw.rs

# Patch & build uv wheel
RUN mkdir wheels && cd uv && \
    sed -i "/boxcar\s*=/c\boxcar = { path = \"../boxcar\" }" Cargo.toml && \
    sed -i "/\[profile.release\]/,/^\[/ s/lto\s*=.*/lto = false/" Cargo.toml
RUN --security=insecure mkdir -p /root/.cargo && chmod 777 /root/.cargo && mount -t tmpfs none /root/.cargo && cd uv && RUSTFLAGS="-C opt-level=0 -C linker=arm-linux-gnueabi-gcc" maturin build --release --strip --profile release --target armv5te-unknown-linux-gnueabi --manylinux off -o /wheels
RUN find /wheels -type f -iname '*.whl' -exec pip install {} \;

# Clone latest release of HASS
RUN TAG=$(curl --silent https://api.github.com/repos/home-assistant/core/releases | jq -r 'map(select(.prerelease==false)) | first | .tag_name') && git clone -b $TAG https://github.com/home-assistant/core && \
    sed -i '/uv==/d' core/requirements.txt

# Install HASS dependencies
RUN pip install --timeout=1000 --extra-index-url https://www.piwheels.org/simple -r core/requirements_all.txt

# Install HASS core package
RUN pip install --no-deps homeassistant

# Cleanup
RUN pip cache purge

FROM --platform=linux/arm/v5 debian:trixie as runner

RUN apt update && DEBIAN_FRONTEND=noninteractive && apt install -y \
    curl wget unzip jq rustc build-essential cmake autoconf pkg-config \
    python3.13-full python3.13-dev git bluez libffi-dev libssl-dev \
    libjpeg-dev zlib1g-dev libopenjp2-7 libtiff6 libturbojpeg0-dev tzdata \
    libudev-dev libpcap-dev libyaml-dev libxml2 libxslt-dev automake doxygen \
    graphviz imagemagick libasound2-dev libass-dev libavcodec-dev libavdevice-dev \
    libavfilter-dev libavformat-dev libavutil-dev libfreetype6-dev libgmp-dev \
    libmp3lame-dev libopencore-amrnb-dev libopencore-amrwb-dev libopus-dev librtmp-dev \
    libsdl2-dev libsdl2-image-dev libsdl2-mixer-dev libsdl2-net-dev libsdl2-ttf-dev \
    libsnappy-dev libsoxr-dev libssh-dev libtool libv4l-dev libva-dev libvdpau-dev \
    libvo-amrwbenc-dev libvorbis-dev libwebp-dev libx264-dev libx265-dev libxcb-shape0-dev \
    libxcb-shm0-dev libxcb-xfixes0-dev libxcb1-dev libxml2-dev meson nasm texinfo \
    yasm libdrm-dev python3 --no-install-recommends && apt clean && apt autoclean

RUN apt install -y ffmpeg python-is-python3

RUN mkdir /config

# Install go2rtc binary
COPY --from=go2rtc-builder ./go2rtc_linux_armv5 ./go2rtc_linux_armv5
RUN mv go2rtc_linux_armv5 /bin/go2rtc && chmod +x /bin/go2rtc

# Install cargo
COPY --from=cargo-builder /cargo/target/armv5te-unknown-linux-gnueabi/debian/*.deb .
RUN dpkg -i *.deb

# Copy Python VENV from builder
COPY --from=hass-builder /opt/venv /opt/venv

RUN ldconfig && apt clean

ENV PATH="/opt/venv/bin:$PATH"
ENV VIRTUAL_ENV="/opt/venv"

# Fix psutil error
RUN pip install --upgrade psutil 

CMD ["hass","-v","-c","/config"]
