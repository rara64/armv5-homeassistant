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

FROM --platform=linux/arm/v5 python:3.10-bullseye AS hass-builder

# Setup environment for Rust compilation
RUN cp /etc/apt/sources.list /etc/apt/tmp
RUN echo "deb http://deb.debian.org/debian testing main contrib non-free" >> /etc/apt/sources.list
RUN apt update && DEBIAN_FRONTEND=noninteractive && apt install -y rustc cargo build-essential cmake --no-install-recommends
RUN mv /etc/apt/tmp /etc/apt/sources.list
COPY --from=cargo-builder /cargo/target/armv5te-unknown-linux-gnueabi/debian/*.deb .
RUN dpkg -i *.deb

# Install packages needed by HASS and components
RUN apt update && DEBIAN_FRONTEND=noninteractive && apt install -y jq git bluez libffi-dev libssl-dev libjpeg-dev zlib1g-dev autoconf libopenjp2-7 libtiff5 libturbojpeg0-dev tzdata libudev-dev libavformat-dev libavcodec-dev libavdevice-dev libavutil-dev libswscale-dev libswresample-dev libavfilter-dev libpcap-dev libturbojpeg0 libyaml-dev libxml2 --no-install-recommends

# Setup Python VENV
RUN python -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"
RUN pip install --no-cache-dir wheel

# Clone latest release of HASS
RUN TAG=$(curl --silent https://api.github.com/repos/home-assistant/core/releases | jq -r 'map(select(.prerelease==false)) | first | .tag_name') && git clone -b $TAG https://github.com/home-assistant/core

# Install & build HASS components (--securit=insecure & tmpfs: workaround for spurious network error when fetching crates.io-index)
RUN --security=insecure mkdir -p /root/.cargo/registry && chmod 777 /root/.cargo/registry && mount -t tmpfs none /root/.cargo/registry && pip install --no-cache-dir --use-deprecated=legacy-resolver -r core/requirements_all.txt

# Install HASS core package
RUN pip install --no-cache-dir homeassistant

# Cleanup
RUN pip cache purge && rm -rf core

FROM --platform=linux/arm/v5 python:3.10-slim-bullseye AS runner

# Install packages needed by HASS and components
RUN cp /etc/apt/sources.list /etc/apt/tmp
RUN echo "deb http://deb.debian.org/debian testing main contrib non-free" >> /etc/apt/sources.list
RUN apt update && DEBIAN_FRONTEND=noninteractive && apt install -y build-essential cmake --no-install-recommends
RUN mv /etc/apt/tmp /etc/apt/sources.list
RUN apt update && DEBIAN_FRONTEND=noninteractive && apt install -y git bluez libffi-dev libssl-dev libjpeg-dev zlib1g-dev autoconf libopenjp2-7 libtiff5 libturbojpeg0-dev tzdata libudev-dev libavformat-dev libavcodec-dev libavdevice-dev libavutil-dev libswscale-dev libswresample-dev libavfilter-dev libpcap-dev libturbojpeg0 libyaml-dev libxml2 --no-install-recommends

# Copy Python VENV from hass-builder to runner
RUN mkdir /config
COPY --from=hass-builder /opt/venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

CMD ["hass","-v","-c","/config"]
