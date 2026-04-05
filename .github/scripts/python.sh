#!/bin/bash

HOMEASSISTANT_TAG=$1

BASE_PYTHON_VERSION=$(skopeo inspect --override-arch arm docker://rara64/armv5-debian-base | jq -r '.Labels.python_version')
REQ_PYTHON=$(curl -s https://pypi.org/pypi/homeassistant/$HOMEASSISTANT_TAG/json | jq -r '.info.requires_python | match("3\\.[0-9]+(\\.[0-9]+)?") | .string')

if [ "$BASE_PYTHON_VERSION" = "$REQ_PYTHON" ]; then
  exit 0
else
  exit 3
fi
