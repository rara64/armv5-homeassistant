# syntax = docker/dockerfile:experimental
FROM --platform=linux/arm/v5 rara64/armv5-debian-base:latest AS hass-builder
ARG WHEELS
ARG WHEELS2

# Install latest cargo from rara64/armv5te-cargo repo
RUN wget $(curl --silent https://api.github.com/repos/rara64/armv5te-cargo/releases/latest | jq -r '.assets[0].browser_download_url')
RUN dpkg -i *.deb

# Setup Python VENV
RUN python3.12 -m venv /opt/venv
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
RUN pip install $(find /wheels -type f -iname 'uv*')
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
RUN --security=insecure mkdir -p /root/.cargo && chmod 777 /root/.cargo && mount -t tmpfs none /root/.cargo && pip install --extra-index-url https://www.piwheels.org/simple --no-cache-dir --use-deprecated=legacy-resolver -r core/requirements_all.txt

# Install HASS core package
RUN pip install --no-cache-dir homeassistant

# Cleanup
RUN pip cache purge && rm -rf core && rm -rf wheels && rm wheels.zip && rm wheels2.zip

FROM --platform=linux/arm/v5 rara64/armv5-debian-base:latest AS runner

# Copy Python VENV from hass-builder to runner
RUN mkdir /config
COPY --from=hass-builder /opt/venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

CMD ["hass","-v","-c","/config"]
