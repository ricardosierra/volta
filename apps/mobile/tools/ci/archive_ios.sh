#!/bin/bash
set -e

echo "Archiving Xcode project..."
# xcodebuild -project Volta.xcodeproj -scheme Volta archive -archivePath Volta.xcarchive
# xcodebuild -exportArchive -archivePath Volta.xcarchive -exportOptionsPlist ExportOptions.plist -exportPath output/
echo "Done."
