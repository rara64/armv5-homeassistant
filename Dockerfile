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
RUN pip install --no-cache-dir pip wheel

# Extract prebuilt wheels from `Build 1st batch of wheels` job
COPY $WHEELS .
RUN unzip wheels.zip -d wheels

# Extract prebuilt wheels from `Build 2nd batch of wheels` job
COPY $WHEELS2 .
RUN unzip wheels2.zip -d wheels

# Extract prebuilt wheels from `Build 3rd batch of wheels` job
COPY $WHEELS3 .
RUN unzip wheels3.zip -d wheels

# Extract prebuilt wheels from `Build 4th batch of wheels` job
COPY $WHEELS4 .
RUN unzip wheels4.zip -d wheels

# Install prebuilt wheels from wheel jobs
RUN pip install $(find /wheels -type f -iname 'numpy*')
RUN pip install $(find /wheels -type f -iname 'uv*')
RUN pip install $(find /wheels -type f -iname 'maturin*')
RUN pip install --no-cache-dir $(find . -type f -iname 'pandas*')
RUN pip install --no-cache-dir $(find . -type f -iname 'pynacl*')
RUN pip install $(find /wheels -type f -iname 'crypto*')
RUN pip install --no-cache-dir $(find . -type f -iname 'orjson*')
RUN pip install $(find /wheels -type f -iname 'zeroconf*')
RUN pip install $(find /wheels -type f -iname 'PyYAML*')
RUN pip install $(find /wheels -type f -iname 'jiter*')
RUN pip install $(find /wheels -type f -iname 'tokenizers*')
RUN pip install $(find /wheels -type f -iname 'pydantic_core*')
RUN pip install $(find /wheels -type f -iname 'ha-av*')

# Clone latest release of HASS
RUN TAG=$(curl --silent https://api.github.com/repos/home-assistant/core/releases | jq -r 'map(select(.prerelease==false)) | first | .tag_name') && git clone -b $TAG https://github.com/home-assistant/core

# Install & build HASS components (--securit=insecure & tmpfs: workaround for spurious network error when fetching crates.io-index)
RUN --security=insecure mkdir -p /root/.cargo && chmod 777 /root/.cargo && mount -t tmpfs none /root/.cargo && pip install --no-cache-dir -r core/requirements_all.txt

# Install HASS core package
RUN pip install --no-cache-dir homeassistant

# Cleanup
RUN pip cache purge && rm -rf core && rm -rf wheels && rm wheels.zip && rm wheels2.zip && rm wheels3.zip && rm wheels4.zip

FROM --platform=linux/arm/v5 rara64/armv5-debian-base:latest AS runner
ARG GO2RTC

# Copy Python VENV from hass-builder to runner
RUN mkdir /config

# Install go2rtc binary
RUN curl -o /bin/go2rtc -L "https://github.com/AlexxIT/go2rtc/releases/download/v${GO2RTC}/go2rtc_linux_arm" \
    && chmod +x /bin/go2rtc

COPY --from=hass-builder /opt/venv /opt/venv
RUN ldconfig

ENV PATH="/opt/venv/bin:$PATH"

CMD ["hass","-v","-c","/config"]
