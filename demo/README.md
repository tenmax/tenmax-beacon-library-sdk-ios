# TenMaxBeaconPublicDemoApp

A public demonstration application showcasing the integration and usage of the TenMaxAdBeaconSDK via XCFramework. This demo app demonstrates how to integrate the pre-built XCFramework into your iOS project for beacon detection, creative content delivery, and notification handling.

## Overview

The TenMaxBeaconPublicDemoApp serves as a reference implementation for integrating the TenMaxAdBeaconSDK using XCFramework. Unlike the internal demo app that uses Swift Package Manager, this version demonstrates how to integrate the pre-built XCFramework directly into your project, making it ideal for distribution and third-party integration.

## Key Features

- **XCFramework Integration**: Direct integration of pre-built TenMaxAdBeaconSDK.xcframework
- **SDK Initialization**: Complete setup and configuration of TenMaxAdBeaconSDK
- **Permission Management**: Automated handling of location, Bluetooth, notification, and app tracking permissions
- **Beacon Detection**: Real-time scanning for both iBeacons and custom beacons
- **Creative Content Display**: Dynamic rendering of advertising content based on beacon proximity
- **Notification System**: Local notification delivery with data support
- **User Profile Management**: Client profile configuration with phone and email
- **Data Persistence**: Automatic saving and restoration of user profile data across app restarts
- **Automatic IDFA Handling**: Smart advertising ID retrieval with iOS 14+ privacy compliance
- **Background Scanning**: Continuous beacon monitoring when app is backgrounded

## Getting Started

### Prerequisites

- iOS 12.0 or later
- Xcode 16.2.0 or later
- Swift 5.5 or later

### Installation

1. Navigate to the public demo app directory
2. Open `TenMaxBeaconPublicDemoApp.xcworkspace` in Xcode
3. Build and run the application on a physical device (required for beacon functionality)

### XCFramework Integration

This demo app includes the `TenMaxAdBeaconSDK.xcframework` directly in the project.

### Quick Build

Use the provided build script for automated compilation:

```bash
./build_and_run.sh
```

This script will:
- Build the demo application using the included XCFramework
- Prepare the workspace for testing

## Application Flow

### 1. Initial Setup
- App launches and initializes the TenMaxAdBeaconSDK
- Automatically requests necessary permissions (location, Bluetooth, notifications, app tracking)
- Configures client profile with user information

### 2. User Profile Configuration
- Enter phone number and email address (optional)
- Submit profile information to update SDK configuration
- Profile data is automatically saved and restored across app restarts
- Advertising ID is automatically retrieved from system when available
- Profile data is used for personalized content delivery

    #### Data Persistence Features
  - **Automatic Saving**: User profile data is automatically saved to UserDefaults
  - **Seamless Restoration**: Previously entered data is restored when app restarts
  - **Privacy Compliant**: Advertising ID retrieval respects iOS 14+ tracking preferences
  - **Manual Cleanup**: Data can be cleared using SDK methods when needed

### 3. Beacon Scanning
- SDK automatically begins scanning for nearby beacons
- Supports both Apple iBeacons and custom beacon formats
- Real-time detection and proximity monitoring

### 4. Content Delivery
- When beacons are detected, relevant creative content is retrieved
- Content is displayed within the app interface
- Local notifications are sent for important updates

## Architecture Overview

### Core Components

**MainPageViewController**
- Primary interface for user interaction
- Handles profile configuration and permission requests
- Displays real-time beacon detection status and logs

**AppBeaconManager**
- Singleton manager for SDK lifecycle
- Handles SDK initialization and configuration
- Manages client profile updates and beacon callbacks

**PermissionManager**
- Centralized permission handling
- Requests location, Bluetooth, notification, and app tracking access
- Provides permission status monitoring

**CongratulationsViewController**
- Handles notification tap events
- Processes data from beacon-triggered notifications
- Demonstrates notification-to-app flow

**NotificationHelper**
- Utility class for local notification management
- Formats and schedules beacon-related notifications
- Handles notification content and actions

## Configuration

### Required Permissions

The application requires several permissions to function properly. These are automatically requested on first launch:

- **Location Services**: Required for beacon detection and proximity monitoring
- **Bluetooth**: Necessary for scanning BLE beacons
- **Notifications**: Enables delivery of beacon-triggered alerts
- **App Tracking Transparency**: Required for advertising identifier access (iOS 14+)

### Info.plist Configuration

The demo app's Info.plist includes essential permission descriptions:

```xml
<!-- Location Permission -->
<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>We need location permission to detect nearby beacons and provide relevant services.</string>
<key>NSLocationWhenInUseUsageDescription</key>
<string>We need location permission to detect nearby beacons and provide relevant services.</string>

<!-- Bluetooth Permission -->
<key>NSBluetoothAlwaysUsageDescription</key>
<string>We need Bluetooth permission to scan for nearby beacons and provide relevant services.</string>

<!-- App Tracking Transparency -->
<key>NSUserTrackingUsageDescription</key>
<string>This app uses advertising identifier to provide personalized beacon-based advertising content and analytics. Your privacy is important to us and this data is used solely for improving your advertising experience.</string>

<!-- Background Modes -->
<key>UIBackgroundModes</key>
<array>
    <string>bluetooth-central</string>
    <string>location</string>
</array>
```

## Development Setup

### Workspace Structure

The demo app uses an Xcode Workspace that includes:
- **TenMaxBeaconPublicDemoApp**: The main demo application target
- **TenMaxAdBeaconSDK.xcframework**: Pre-built framework included in the project

### Build and Run

**Option 1: Using Build Script**
```bash
./build_and_run.sh
```

**Option 2: Direct Xcode**
```bash
open TenMaxBeaconPublicDemoApp.xcworkspace
```

**Option 3: Command Line Build**
```bash
xcodebuild -workspace TenMaxBeaconPublicDemoApp.xcworkspace \
           -scheme TenMaxBeaconPublicDemoApp \
           -configuration Debug \
           -sdk iphonesimulator
```

## Implementation Guide

### SDK Integration Pattern

The demo app follows best practices for SDK integration:

```swift
// 1. Initialize with client profile
let clientProfile = ClientProfile(
    phoneNumber: phoneNumber,
    email: email,
    appName: "TenMaxBeaconDemo",
    advertisingId: advertisingId
)

// 2. Configure SDK with environment
TenMaxAdBeaconSDK.shared().initiate(
    clientProfile: clientProfile,
    environment: .stage,
    callback: beaconCallback
)

// 3. Handle beacon events
class BeaconCallback: TenMaxAdBeaconCallback {
    func onReceiveCreative(_ creative: Creative) {
        // Handle creative content
    }

    func onError(_ error: TenMaxAdBeaconError) {
        // Handle errors
    }
}
```

### Permission Management

Demonstrates comprehensive permission handling:

```swift
// Request all required permissions
permissionManager.requestAllPermissions()

// Check individual permission status
let hasLocationPermission = permissionManager.hasLocationPermission()
let hasBluetoothPermission = permissionManager.hasBluetoothPermission()
let hasNotificationPermission = permissionManager.hasNotificationPermission()
```

### Thread Safety

All SDK callbacks are automatically dispatched to the main thread, ensuring safe UI updates without additional threading considerations.

## Troubleshooting

### Common Issues

**Beacon Detection Not Working**
- Ensure location permissions are granted
- Verify Bluetooth is enabled
- Test on physical device (simulator limitations)
- Check beacon configuration in SDK settings

**Notifications Not Appearing**
- Confirm notification permissions are granted
- Verify app is not in Do Not Disturb mode
- Check notification settings in iOS Settings app

**Build Errors**
- Clean build folder (⌘+Shift+K)
- Update to latest Xcode version
- Verify workspace dependencies are resolved

## System Requirements

- **iOS**: 12.0 or later
- **Xcode**: 16.2.0 or later
- **Swift**: 5.5 or later
- **Device**: Physical iOS device (beacon functionality requires hardware)

## Support

For technical support or questions about the demo app:
1. Check the main SDK documentation
2. Review the implementation examples in this demo
3. Contact the TenMax development team
