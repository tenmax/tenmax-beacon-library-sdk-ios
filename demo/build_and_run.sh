#!/bin/bash

cd "$(dirname "$0")"

echo "Building TenMaxBeaconPublicDemoApp..."
xcodebuild -workspace TenMaxBeaconPublicDemoApp.xcworkspace -scheme TenMaxBeaconPublicDemoApp -configuration Debug -sdk iphonesimulator

echo "Build completed successfully!"
echo "You can now open TenMaxBeaconPublicDemoApp.xcworkspace in Xcode and run the app."
