#!/bin/bash

LINK=$(curl --silent -H "Authorization: token ${WHEELS_TOKEN}" \
  "https://api.github.com/repos/rara64/armv5-homeassistant/actions/artifacts?per_page=1000&page=1" \
  | jq -r '.artifacts[] | select(.name == "maturin") | .archive_download_url' | head -n 1)

curl -L -H "Authorization: token ${WHEELS_TOKEN}" -o maturin.zip "$LINK" || echo 'MATURIN download failed!'
7z e maturin.zip -o./maturin -y || echo 'MATURIN extract failed!'

MATURIN_REQUIRED_VER=$(curl -s https://api.github.com/repos/PyO3/maturin/releases/latest | jq -r .tag_name | sed 's/^v//')
MATURIN_BUILD_VER=$(cat ./maturin/maturin_ver.txt)

if [ "$MATURIN_REQUIRED_VER" = "$MATURIN_BUILD_VER" ]; then
  exit 0
else
  exit 3
fi
