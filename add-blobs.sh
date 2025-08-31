#!/bin/bash

set -eux

source ./src/meta-info/blobs-versions.env
source ./rel.env

mkdir -p "$TMP_DIR"

function down_add_blob {
  BLOBS_GROUP=$1
  FILE=$2
  URL=$3
  if [ ! -f "blobs/${BLOBS_GROUP}/${FILE}" ];then
    echo "Downloads resource from the Internet ($URL -> $TMP_DIR/$FILE)"
    curl -L "$URL" --output "$TMP_DIR/$FILE"
    echo "Adds blob ($TMP_DIR/$FILE -> $BLOBS_GROUP/$FILE), starts tracking blob in config/blobs.yml for inclusion in packages"
    bosh add-blob "$TMP_DIR/$FILE" "$BLOBS_GROUP/$FILE"
  fi
}

down_add_blob "redis" "redis-${REDIS_VERSION}.tar.gz" "$REDIS_URL"
down_add_blob "redis_exporter" "redis_exporter-v${REDIS_EXPORTER_VERSION}.tar.gz" "${REDIS_EXPORTER_URL}"

echo "Download blobs into blobs/ based on config/blobs.yml"
bosh sync-blobs

echo "Upload previously added blobs that were not yet uploaded to the blobstore. Updates config/blobs.yml with returned blobstore IDs."
bosh upload-blobs
