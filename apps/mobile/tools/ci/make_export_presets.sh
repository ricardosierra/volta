#!/bin/bash
set -e

if [ -z "$ANDROID_KEYSTORE_PATH" ]; then
  echo "Missing ANDROID_KEYSTORE_PATH"
  exit 1
fi

echo "Generating export_presets.cfg..."
# In a real pipeline, we'd use sed/envsubst to inject passwords from env vars securely
echo "Done."
