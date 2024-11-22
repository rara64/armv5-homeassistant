# syntax = docker/dockerfile:experimental
FROM --platform=linux/arm/v5 debian:trixie
ARG WHEELS
ARG WHEELS2
ARG WHEELS3
ARG WHEELS4
ARG GO2RTC

RUN apt update && DEBIAN_FRONTEND=noninteractive && apt install -y \
    curl wget unzip jq rustc build-essential cmake autoconf pkg-config \
    python3.12 python3.12-venv python3.12-dev git bluez libffi-dev libssl-dev \
    libjpeg-dev zlib1g-dev libopenjp2-7 libtiff6 libturbojpeg0-dev tzdata \
    libudev-dev libpcap-dev libyaml-dev libxml2 libxslt-dev automake doxygen \
    graphviz imagemagick libasound2-dev libass-dev libavcodec-dev libavdevice-dev \
    libavfilter-dev libavformat-dev libavutil-dev libfreetype6-dev libgmp-dev \
    libmp3lame-dev libopencore-amrnb-dev libopencore-amrwb-dev libopus-dev librtmp-dev \
    libsdl2-dev libsdl2-image-dev libsdl2-mixer-dev libsdl2-net-dev libsdl2-ttf-dev \
    libsnappy-dev libsoxr-dev libssh-dev libtool libv4l-dev libva-dev libvdpau-dev \
    libvo-amrwbenc-dev libvorbis-dev libwebp-dev libx264-dev libx265-dev libxcb-shape0-dev \
    libxcb-shm0-dev libxcb-xfixes0-dev libxcb1-dev libxml2-dev lzma-dev meson nasm texinfo \
    yasm libdrm-dev python3-dev python3-pip --no-install-recommends && apt clean && apt autoclean

# Install latest cargo from rara64/armv5te-cargo repo
RUN wget $(curl --silent https://api.github.com/repos/rara64/armv5te-cargo/releases/latest | jq -r '.assets[0].browser_download_url') && \
    dpkg -i *.deb && rm -f *.deb && apt clean

# Setup Python VENV
RUN python3.12 -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"
RUN pip install --no-cache-dir wheel

# Copy prebuilt wheels from other workflows
COPY $WHEELS .
COPY $WHEELS2 .
COPY $WHEELS3 .
COPY $WHEELS4 .

# Install prebuilt wheels from wheel jobs
RUN unzip wheels.zip -d wheels && \
    unzip wheels2.zip -d wheels && \
    unzip wheels3.zip -d wheels && \
    unzip wheels4.zip -d wheels && \
    find /wheels -type f -iname '*.whl' -exec pip install --no-cache-dir {} + && \
    rm -rf wheels && rm wheels.zip && rm wheels2.zip && rm wheels3.zip && rm wheels4.zip

# Clone, Install & Build HASS (--securit=insecure & tmpfs: workaround for spurious network error)
RUN TAG=$(curl --silent https://api.github.com/repos/home-assistant/core/releases | jq -r 'map(select(.prerelease==false)) | first | .tag_name') && \
    git clone --depth 1 -b $TAG https://github.com/home-assistant/core && \
    pip cache purge && CARGO_INCREMENTAL=0 && \
    pip install --verbose --timeout=1000 --extra-index-url https://www.piwheels.org/simple --no-cache-dir --use-deprecated=legacy-resolver -r core/requirements_all.txt && \
    rm -rf /root/.cargo && rm -rf core && rm -rf /tmp/*

RUN pip install --no-cache-dir homeassistant && \
    pip cache purge

# Install go2rtc binary
RUN curl -o /bin/go2rtc -L "https://github.com/AlexxIT/go2rtc/releases/download/v${GO2RTC}/go2rtc_linux_arm" \
    && chmod +x /bin/go2rtc

RUN ldconfig && mkdir /config

CMD ["hass","-v","-c","/config"]
