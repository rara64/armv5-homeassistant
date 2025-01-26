# syntax = docker/dockerfile:experimental
FROM --platform=linux/arm/v5 rara64/armv5-debian-base:latest as hass-builder

RUN uname -m

ARG DEPS

# Install latest cargo from rara64/armv5te-cargo repo
RUN wget $(curl --silent https://api.github.com/repos/rara64/armv5te-cargo/releases/latest | jq -r '.assets[0].browser_download_url')
RUN dpkg -i *.deb

# Setup Python VENV
RUN python3.12 -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"
RUN pip install wheel

ENV CARGO_NET_GIT_FETCH_WITH_CLI="true"
ENV CARGO_TERM_PROGRESS_WHEN="never"
ENV CARGO_BUILD_JOBS=2
ENV RUSTFLAGS="-C codegen-units=1"

# Install pre-built dependencies
COPY $DEPS .
RUN unzip -o -j deps.zip -d wheels && \
    find wheels/ -type f -iname 'maturin*' -exec pip install {} --find-links ./wheels \; && \
    find wheels/ -type f -iname 'rpds_py*' -exec pip install {} --find-links ./wheels \; && \
    find wheels/ -type f -iname 'token*' -exec pip install {} --find-links ./wheels \; && \
    find wheels/ -type f -iname 'pyyaml*' -exec pip install {} --find-links ./wheels \; && \
    find wheels/ -type f -iname 'jiter*' -exec pip install {} --find-links ./wheels \; && \
    find wheels/ -type f -iname 'pydantic*' -exec pip install {} --find-links ./wheels \; && \
    find wheels/ -type f -iname 'numpy*' -exec pip install {} --find-links ./wheels \; && \
    find wheels/ -type f -iname 'cffi*' -exec pip install {} --find-links ./wheels \; && \
    find wheels/ -type f -iname 'patchelf*' -exec pip install {} --find-links ./wheels \; && \
    find wheels/ -type f -iname '*.whl' -exec pip install {} --find-links ./wheels \;

# Clone latest release of HASS
RUN TAG=$(curl --silent https://api.github.com/repos/home-assistant/core/releases | jq -r 'map(select(.prerelease==false)) | first | .tag_name') && git clone -b $TAG https://github.com/home-assistant/core

# Install HASS dependencies
RUN pip install --timeout=1000 --extra-index-url https://www.piwheels.org/simple -r core/requirements_all.txt

# Install HASS core package
RUN pip install homeassistant

# Cleanup
RUN pip cache purge

FROM --platform=linux/arm/v5 rara64/armv5-debian-base:latest as runner

# Copy Python VENV from hass-builder to runner
RUN mkdir /config

# Install go2rtc binary
RUN export TAG=$(curl --silent https://api.github.com/repos/home-assistant/core/releases | jq -r 'map(select(.prerelease==false)) | first | .tag_name') && \
    export GO2RTC=$(curl -s https://raw.githubusercontent.com/home-assistant/core/refs/tags/$TAG/Dockerfile | grep -oP 'curl -L https://github.com/AlexxIT/go2rtc/releases/download/v\K[0-9.]+') && \
    curl -o /bin/go2rtc -L "https://github.com/AlexxIT/go2rtc/releases/download/v${GO2RTC}/go2rtc_linux_arm" \
    && chmod +x /bin/go2rtc

RUN wget $(curl --silent https://api.github.com/repos/rara64/armv5te-cargo/releases/latest | jq -r '.assets[0].browser_download_url') && dpkg -i *.deb && rm *.deb

COPY --from=hass-builder /opt/venv /opt/venv

RUN ldconfig && apt clean

ENV PATH="/opt/venv/bin:$PATH"

RUN pip install --upgrade psutil 

CMD ["hass","-v","-c","/config"]
