#!/usr/bin/env sh

echo '(1/2) Copying frontend data into shared volume'
mkdir -p "${SHARE_DIR}"
cp -rf ${OUTPUT_DIR}/* ${SHARE_DIR}

echo '(2/2) Running command passed to container'
echo "Running: $*"
sh -c "$*"
