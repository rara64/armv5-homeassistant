# syntax = docker/dockerfile:experimental
FROM --platform=linux/arm/v5 rara64/armv5-debian-base:latest
ARG CARGO_DEB
ARG MATURIN_WHL
ARG WHEEL_VER
ARG NUMPY_WHL
ARG ANTHROPIC_WHL

ENV CARGO_NET_GIT_FETCH_WITH_CLI="true"
ENV CARGO_TERM_PROGRESS_WHEN="never"

# Setup Python VENV
RUN python -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

# Install maturin & other wheels
COPY $MATURIN_WHL .
COPY $NUMPY_WHL .
# COPY $ANTHROPIC_WHL /wheels
RUN find . -maxdepth 1 -name "*.whl" -exec pip install {} \;
# RUN find /wheels -maxdepth 1 -name "*.whl" -exec pip install {} \;

# Install cargo
COPY $CARGO_DEB .
RUN dpkg -i *.deb

# Build anthropic
RUN pip install --find-links . anthropic==$WHEEL_VER

# Remove old wheels if new wheels found
RUN if test -d /root/.cache/pip/wheels; then rm -rf /wheels; fi
