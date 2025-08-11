#!/bin/bash

cd "$(dirname "$0")"

# Default to Beta scheme if no argument provided
SCHEME="TenMaxBeaconPublicDemoApp-Beta"
CONFIGURATION="Debug"

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --release)
            SCHEME="TenMaxBeaconPublicDemoApp-Release"
            CONFIGURATION="Release"
            shift
            ;;
        --beta)
            SCHEME="TenMaxBeaconPublicDemoApp-Beta"
            CONFIGURATION="Debug"
            shift
            ;;
        --help|-h)
            echo "Usage: $0 [--beta|--release] [--help]"
            echo ""
            echo "Options:"
            echo "  --beta     Build using Beta scheme (default)"
            echo "  --release  Build using Release scheme"
            echo "  --help     Show this help message"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

echo "Building TenMaxBeaconPublicDemoApp with scheme: $SCHEME..."
echo "Configuration: $CONFIGURATION"

# Build the project
if xcodebuild -workspace TenMaxBeaconPublicDemoApp.xcworkspace \
               -scheme "$SCHEME" \
               -configuration "$CONFIGURATION" \
               -sdk iphonesimulator \
               -quiet; then
    echo "Build completed successfully!"
    echo "📱 You can now open TenMaxBeaconPublicDemoApp.xcworkspace in Xcode and run the app."
    echo ""
    echo "Available schemes:"
    echo "  • TenMaxBeaconPublicDemoApp-Beta (Debug configuration)"
    echo "  • TenMaxBeaconPublicDemoApp-Release (Release configuration)"
else
    echo "Build failed!"
    echo "Please check the error messages above and try again."
    exit 1
fi