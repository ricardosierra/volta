#!/bin/bash
set -e

echo "Checking for debug artifacts in codebase..."
if grep -r "TODO: " apps/mobile/src/; then
  echo "ERROR: Unresolved TODOs found in src/"
  exit 1
fi

if [ -d "apps/mobile/addons/gut" ]; then
  echo "ERROR: addons/gut must not be shipped!"
  exit 1
fi

echo "Release build is clean."
