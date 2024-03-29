# syntax = docker/dockerfile:experimental
FROM --platform=linux/arm/v5 python:3.12-bullseye AS hass-builder
ARG WHEELS
ARG WHEELS2

# Setup environment for Rust compilation
RUN cp /etc/apt/sources.list /etc/apt/tmp
RUN echo "deb http://deb.debian.org/debian testing main contrib non-free" >> /etc/apt/sources.list
RUN apt update && DEBIAN_FRONTEND=noninteractive && apt install -y unzip jq rustc build-essential cmake --no-install-recommends
RUN mv /etc/apt/tmp /etc/apt/sources.list

# Install latest cargo from rara64/armv5te-cargo repo
RUN wget $(curl --silent https://api.github.com/repos/rara64/armv5te-cargo/releases/latest | jq -r '.assets[0].browser_download_url')
RUN dpkg -i *.deb

# Install packages needed by HASS and components
RUN apt update && DEBIAN_FRONTEND=noninteractive && apt install -y git bluez libffi-dev libssl-dev libjpeg-dev zlib1g-dev autoconf libopenjp2-7 libtiff5 libturbojpeg0-dev tzdata libudev-dev libavformat-dev libavcodec-dev libavdevice-dev libavutil-dev libswscale-dev libswresample-dev libavfilter-dev libpcap-dev libturbojpeg0 libyaml-dev libxml2 --no-install-recommends

# Setup Python VENV
RUN python -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"
RUN pip install --no-cache-dir pip wheel

# Extract prebuilt wheels from rara64/armv5-homeassistant-wheels repo
COPY $WHEELS .
RUN unzip wheels.zip -d wheels

# Extract prebuilt wheels from rara64/armv5-homeassistant-wheels-batch2 repo
COPY $WHEELS2 .
RUN unzip wheels2.zip -d wheels

# Install prebuilt wheels from both wheels repos
RUN pip install $(find /wheels -type f -iname 'numpy*')
# RUN TAG=$(curl --silent https://api.github.com/repos/home-assistant/core/releases | jq -r 'map(select(.prerelease==false)) | first | .tag_name') \
# && VERSION=$(curl --silent https://raw.githubusercontent.com/home-assistant/core/$TAG/homeassistant/package_constraints.txt | grep -i "numpy=" | cut -d "=" -f3) \
# && pip install --no-cache-dir numpy==$VERSION

RUN pip install --no-cache-dir $(find . -type f -iname 'pandas*')
RUN pip install --no-cache-dir $(find . -type f -iname 'pynacl*')
RUN pip install $(find /wheels -type f -iname 'crypto*')
RUN pip install --no-cache-dir $(find . -type f -iname 'orjson*')

# Clone latest release of HASS
RUN TAG=$(curl --silent https://api.github.com/repos/home-assistant/core/releases | jq -r 'map(select(.prerelease==false)) | first | .tag_name') && git clone -b $TAG https://github.com/home-assistant/core

# Install & build HASS components (--securit=insecure & tmpfs: workaround for spurious network error when fetching crates.io-index)
RUN --security=insecure mkdir -p /root/.cargo/registry && chmod 777 /root/.cargo/registry && mount -t tmpfs none /root/.cargo/registry && pip install --extra-index-url https://www.piwheels.org/simple --no-cache-dir --use-deprecated=legacy-resolver -r core/requirements_all.txt

# Install HASS core package
RUN pip install --no-cache-dir homeassistant

# Cleanup
RUN pip cache purge && rm -rf core && rm -rf wheels && rm wheels.zip && rm wheels2.zip

FROM --platform=linux/arm/v5 python:3.12-slim-bullseye AS runner

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
