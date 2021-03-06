#!/usr/bin/env bash

set -e
set -x

cd $(dirname ${0:-})

while IFS=, read -r patch_version _minor_version _major_version; do
  ./build_version.sh "$patch_version"
done < versions.csv
