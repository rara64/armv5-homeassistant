# syntax = docker/dockerfile:experimental
FROM --platform=linux/arm/v5 rara64/armv5-debian-base:latest AS hass-builder
ARG WHEELS
ARG WHEELS2
ARG WHEELS3
ARG WHEELS4

# Install latest cargo from rara64/armv5te-cargo repo
RUN wget $(curl --silent https://api.github.com/repos/rara64/armv5te-cargo/releases/latest | jq -r '.assets[0].browser_download_url')
RUN dpkg -i *.deb

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

# Clone latest release of HASS
RUN TAG=$(curl --silent https://api.github.com/repos/home-assistant/core/releases | jq -r 'map(select(.prerelease==false)) | first | .tag_name') && git clone -b $TAG https://github.com/home-assistant/core

# Install & build HASS components
RUN pip install --timeout=1000 --extra-index-url https://www.piwheels.org/simple --no-cache-dir -r core/requirements_all.txt

# Install HASS core package
RUN pip install --no-cache-dir homeassistant

# Cleanup
RUN pip cache purge

FROM --platform=linux/arm/v5 rara64/armv5-debian-base:latest AS runner
ARG GO2RTC

# Copy Python VENV from hass-builder to runner
RUN mkdir /config

# Install go2rtc binary
RUN curl -o /bin/go2rtc -L "https://github.com/AlexxIT/go2rtc/releases/download/v${GO2RTC}/go2rtc_linux_arm" \
    && chmod +x /bin/go2rtc

COPY --from=hass-builder /opt/venv /opt/venv

RUN ldconfig && apt clean

ENV PATH="/opt/venv/bin:$PATH"

CMD ["hass","-v","-c","/config"]
