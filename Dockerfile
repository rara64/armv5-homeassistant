# syntax = docker/dockerfile:experimental
FROM --platform=linux/arm/v5 rara64/armv5-debian-base:latest
ARG WHEELS
ARG WHEELS2
ARG WHEELS3
ARG WHEELS4
ARG GO2RTC

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
    pip cache purge && \
    pip install --verbose --timeout=1000 --extra-index-url https://www.piwheels.org/simple --no-cache-dir --use-deprecated=legacy-resolver -r core/requirements_all.txt && \
    rm -rf /root/.cargo && rm -rf core && rm -rf /tmp/*

RUN pip install --no-cache-dir homeassistant && \
    pip cache purge

# Install go2rtc binary
RUN curl -o /bin/go2rtc -L "https://github.com/AlexxIT/go2rtc/releases/download/v${GO2RTC}/go2rtc_linux_arm" \
    && chmod +x /bin/go2rtc

RUN ldconfig && mkdir /config

CMD ["hass","-v","-c","/config"]
