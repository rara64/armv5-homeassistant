# syntax = docker/dockerfile:experimental
FROM --platform=linux/arm/v5 rara64/armv5-debian-base:latest as hass-builder

ARG DEPS

# Install latest cargo from rara64/armv5te-cargo repo
RUN wget $(curl --silent https://api.github.com/repos/rara64/armv5te-cargo/releases/latest | jq -r '.assets[0].browser_download_url')
RUN dpkg -i *.deb

# Setup Python VENV
RUN python -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

ENV CARGO_NET_GIT_FETCH_WITH_CLI="true"
ENV CARGO_TERM_PROGRESS_WHEN="never"

# Install pre-built dependencies
COPY $DEPS .
RUN find . -maxdepth 1 -type f -iname 'maturin*' -exec pip install {} --find-links . \; && \
    find . -maxdepth 1 -type f -iname 'rpds_py*' -exec pip install {} --find-links . \; && \
    find . -maxdepth 1 -type f -iname 'token*' -exec pip install {} --find-links . \; && \
    find . -maxdepth 1 -type f -iname 'pyyaml*' -exec pip install {} --find-links . \; && \
    find . -maxdepth 1 -type f -iname 'jiter*' -exec pip install {} --find-links . \; && \
    find . -maxdepth 1 -type f -iname 'pydantic*' -exec pip install {} --find-links . \; && \
    find . -maxdepth 1 -type f -iname 'numpy*' -exec pip install {} --find-links . \; && \
    find . -maxdepth 1 -type f -iname 'cffi*' -exec pip install {} --find-links . \; && \
    find . -maxdepth 1 -type f -iname 'patchelf*' -exec pip install {} --find-links . \; && \
    find . -maxdepth 1 -type f -iname '*.whl' -exec pip install {} --find-links . \;

# Clone latest release of HASS
RUN TAG=$(curl --silent https://api.github.com/repos/home-assistant/core/releases | jq -r 'map(select(.prerelease==false)) | first | .tag_name') && git clone -b $TAG https://github.com/home-assistant/core && \
    sed -i '/uv==/d' core/requirements.txt

# Install HASS dependencies
RUN pip install --timeout=1000 --extra-index-url https://www.piwheels.org/simple --find-links . -r core/requirements_all.txt

# Install HASS core package
RUN pip install --no-deps homeassistant

# Cleanup
RUN pip cache purge

FROM --platform=linux/arm/v5 rara64/armv5-debian-base:latest as runner

ARG GO2RTC

# Copy Python VENV from hass-builder to runner
RUN mkdir /config

# Install go2rtc binary
COPY $GO2RTC .
RUN mv go2rtc_linux_armv5 /bin/go2rtc && chmod +x /bin/go2rtc

RUN wget $(curl --silent https://api.github.com/repos/rara64/armv5te-cargo/releases/latest | jq -r '.assets[0].browser_download_url') && dpkg -i *.deb && rm *.deb

COPY --from=hass-builder /opt/venv /opt/venv

RUN ldconfig && apt clean

ENV PATH="/opt/venv/bin:$PATH"
ENV VIRTUAL_ENV="/opt/venv"

# Fix psutil error
RUN pip install --upgrade psutil 

CMD ["hass","-v","-c","/config"]
