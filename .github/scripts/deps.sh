#!/bin/bash

HOMEASSISTANT_TAG=$1
WHEELS_LIST=('anthropic' 'av' 'cryptography' 'deebot' 'elevenlabs' 'matrix' 'numpy' 'orjson' 'pandas' 'pynacl' 'uv' 'zeroconf' 'lxml' 'geocachingapi' 'slixmpp' 'thinqconnect')

#
# Get package constraints for given homeassistant tag
#

wget https://raw.githubusercontent.com/home-assistant/core/$HOMEASSISTANT_TAG/homeassistant/package_constraints.txt
wget https://raw.githubusercontent.com/home-assistant/core/refs/tags/$HOMEASSISTANT_TAG/requirements_all.txt
cat *.txt >> reqs.txt
sed '/^#/d' reqs.txt > filtered_reqs.txt
mv filtered_reqs.txt reqs.txt

#
# Get required version strings of prebuilt wheels
#

declare -A REQUIRED_VERSION

for wheel in "${WHEELS_LIST[@]}"; do
  REQUIRED_VERSION[$wheel]=$(cat reqs.txt | grep -m 1 -i "${wheel}" | awk -F'=' '{print $NF}' | tr -d '\n')
done

#
# Download and extract prebuilt wheels
#

declare -A WHEEL_VERSION

for wheel in "${WHEELS_LIST[@]}"; do
  LINK=$(curl --silent -H "Authorization: token ${WHEELS_TOKEN}" \ 
    "https://api.github.com/repos/rara64/armv5-homeassistant/actions/artifacts?per_page=1000&page=1" \
    | jq -r "first(.artifacts[] | select(.name | test(\"${wheel}\")) | .archive_download_url)")

  curl -L -H "Authorization: token ${WHEELS_TOKEN}" -o "${wheel}.zip" "${LINK}" || echo "${wheel} download failed!"

  7z e ${wheel}.zip -o./deps -y || echo "${wheel} extract failed!"

  if [[ "${wheel}" == "matrix" ]]; then
    WHEEL_VERSION[$wheel]=$(cat "./deps/${wheel}-nio_version.txt")
  elif [[ "${wheel}" == "deebot" ]]; then
    WHEEL_VERSION[$wheel]=$(cat "./deps/${wheel}-client_version.txt")
  else
    WHEEL_VERSION[$wheel]=$(cat "./deps/${wheel}_version.txt")
  fi
done

#
# Remove duplicates or mismatched versions
#

for wheel in "${WHEELS_LIST[@]}"; do 
  required_version=${REQUIRED_VERSION[$wheel]}
  matching_files=$(find ./deps -type f -iname "${wheel}*.whl" -print 2>/dev/null | tr -d '\0')

  if [[ -z "$matching_files" ]]; then
    echo "No matching files found for $wheel. Expected version: ${required_version}"
  else
    for file in $matching_files; do
      if [[ "$file" == *"${required_version}"* ]]; then
        echo "Keeping $file (matches version ${required_version})"
        WHEEL_VERSION[$wheel]="${required_version}"
      else
        echo "Removing $file (does not match version ${required_version})"
        rm -f "$file"
      fi
    done
  fi
done

#
# Compare version strings after cleanup
#

OUTDATED=0

for wheel in "${WHEELS_LIST[@]}"; do
  wh=${WHEEL_VERSION[$wheel]}
  r=${REQUIRED_VERSION[$wheel]}
  
  echo "${wheel}: Prebuilt version => ${wh}, Required version => ${r}"
  if [[ "${wh}" != "${r}" ]]; then
    OUTDATED=1
  fi
done

if [ $OUTDATED -eq 0 ]; then
  exit 0
else
  exit 3
fi
