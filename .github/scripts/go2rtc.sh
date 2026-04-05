#!/bin/bash

LINK=$(curl --silent "https://api.github.com/repos/rara64/armv5-homeassistant/actions/artifacts?per_page=1000&page=1" | jq -r '.artifacts[] | select(.name == "go2rtc") | .archive_download_url' | head -n 1)

curl -L -H "Authorization: token ${WHEELS_TOKEN}" -o go2rtc.zip "$LINK" || echo 'GO2RTC download failed!'
7z e go2rtc.zip -o./go2rtc -y || echo 'GO2RTC extract failed!'

HOMEASSISTANT_TAG=$1
GO2RTC=$(curl -s https://raw.githubusercontent.com/home-assistant/core/refs/tags/$HOMEASSISTANT_TAG/Dockerfile | grep -oP '(?<=--from=)ghcr\.io/alexxit/go2rtc[^ ]+')

GO2RTC_REQUIRED_VER=$(skopeo inspect docker://$GO2RTC | jq -r '.Labels["org.opencontainers.image.version"]')
GO2RTC_BUILD_VER=$(cat ./go2rtc/go2rtc_ver.txt)

if [ "$GO2RTC_REQUIRED_VER" = "$GO2RTC_BUILD_VER" ]; then
  exit 0
else
  exit 3
fi
