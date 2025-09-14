# TenMax Beacon SDK for iOS

[![Version](https://img.shields.io/badge/version-1.0.1-blue.svg)](./VERSION)
[![Platform](https://img.shields.io/badge/platform-iOS%2012.0%2B-lightgrey.svg)](https://developer.apple.com/ios/)
[![Swift](https://img.shields.io/badge/swift-5.5%2B-orange.svg)](https://swift.org/)

A Swift package for integrating TenMax Beacon tracking functionality into iOS applications.

## Features

- **Beacon Detection**: Supports both Apple iBeacon and custom Bluetooth beacon detection with sequential scanning
- **Background Scanning**: Continues beacon scanning even when the app is in the background using Core Location
- **Frequency Capping**: Intelligent frequency control to prevent spam notifications with configurable intervals
- **Beacon Deduplication**: Prevents processing duplicate beacon data within 30-second time windows
- **Network Connectivity**: Automatic network connectivity checking before API calls using Reachability
- **Notification Management**: Handles local notifications with click tracking and creative data content support
- **Thread Safety**: All operations are thread-safe with proper concurrent queue management and automatic main thread callback execution
- **Comprehensive Testing**: Extensive test suite with Quick and Nimble frameworks and mock infrastructure
- **Privacy Compliance**: Includes PrivacyInfo.xcprivacy for App Store privacy requirements

## Installation

### Swift Package Manager

The [Swift Package Manager](https://swift.org/package-manager/) is a tool for automating the distribution of Swift code and is integrated into Xcode.

#### Xcode Project Integration

Go to `File > Add Package Dependencies...`, paste `https://github.com/tenmax/tenmax-beacon-library-sdk-ios` into package URL. After the package is found, you can indicate the exact version of SDK. Then, click the `Add Package` to add the SDK package into your Xcode project.

#### Swift Package Integration

Adding TenMaxBeaconSDK as a dependency into your `Package.swift` and indicating the SDK version.

```swift
dependencies: [
    .package(url: "https://github.com/tenmax/tenmax-beacon-library-sdk-ios", .upToNextMajor(from: "1.1.0"))
]
```

Normally you'll need to add the `TenMaxBeaconSDK` target:

```swift
.product(name: "TenMaxBeaconSDK", package: "TenMaxBeaconSDK")
```

The Package.swift sample like this:

```swift
let package = Package(
    name: "YourPackageName",
    products: [
        .library(name: "YourPackageName", targets: ["YourTargetName"]),
    ],
    dependencies: [
      .package(url: "https://github.com/tenmax/tenmax-beacon-library-sdk-ios", .upToNextMajor(from: "1.1.0"))
    ],
    targets: [
        .target(
            name: "YourTargetName",
            dependencies: [
              .product(name: "TenMaxBeaconSDK", package: "tenmax-beacon-library-sdk-ios")
            ],
        ),
    ]
)
```

### Carthage

[Carthage](https://github.com/Carthage/Carthage) is a decentralized dependency manager that builds your dependencies and provides you with binary frameworks. To integrate TenMaxBeaconSDK into your Xcode project using Carthage, specify it in your `Cartfile`:

```
binary "https://raw.githubusercontent.com/tenmax/tenmax-beacon-library-sdk-ios/main/TenMaxBeaconSDK.json"
```

After Carthage downloaded the `TenMaxBeaconSDK.xcframework` file, you can find the file in the folder `./Carthage/Build`. Make sure you have added `TenMaxBeaconSDK.xcframework` to the "Linked Frameworks and Libraries" section of your target.

## SDK Configuration

### App Configuration

Update your app's `Info.plist` file to add required permission descriptions:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
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
    <string>This app uses advertising identifier to provide personalized beacon-based advertising content and analytics.</string>
    
    <!-- Background Modes -->
    <key>UIBackgroundModes</key>
    <array>
        <string>bluetooth-central</string>
        <string>location</string>
    </array>
</dict>
</plist>
```

### SDK Initiation

TenMax Beacon SDK must be initiated before use, thus, we recommend you to initiate it in your `AppDelegate` class. The SDK would run the initiation in an independent thread pool so won't increase your application launch time.

```swift
import TenMaxBeaconSDK

class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        // Create client profile
        // Phone number and email are optional and require user consent
        // UUID v1 is automatically generated and stored in UserDefaults
        // Device information is automatically collected
        // User data (phone, email) is automatically persisted across app restarts
        let clientProfile = ClientProfile(
            phoneNumber: "0912345678",    // Optional: will be persisted and restored
            email: "user@example.com",    // Optional: will be persisted and restored
            appName: "YourAppName",
            advertisingId: "advertising-id-here"    // Optional: auto-retrieved from system if authorized
        )

        // Initialize SDK
        let callback = BeaconCallback()
        TenMaxAdBeaconSDK.shared().initiate(
            clientProfile: clientProfile,
            callback: callback,
        )

        return true
    }
}
```

## Usage

### Implementing Beacon Callback

Create a callback class to handle beacon events:

```swift
import TenMaxBeaconSDK

// Implement callback interface
class BeaconCallback: TenMaxAdBeaconCallback {
    func onInitialized() {
        print("SDK initialized successfully")

        // Start SDK
        TenMaxAdBeaconSDK.shared().start()
    }

    func onCreativeReceived(creative: TenMaxAdCreative) {
        print("Received creative with data: \(creative.data ?? "No data")")
    }

    func onError(error: TenMaxAdBeaconError) {
        print("Error: \(error.message)")
    }

    func onNotificationClicked(creative: TenMaxAdCreative) {
        print("Notification clicked with data: \(creative.data ?? ""), creativeId: \(creative.creativeId)")
        // Handle data navigation
    }
}
```

### Starting and Stopping the SDK

```swift
// Start SDK (call after successful initialization)
TenMaxAdBeaconSDK.shared().start()

// Stop SDK
TenMaxAdBeaconSDK.shared().stop()

// Check if SDK is currently scanning
let isScanning = TenMaxAdBeaconSDK.shared().isScanning
print("SDK is scanning: \(isScanning)")
```

### Updating Client Profile

```swift
// Update client profile
let updatedProfile = ClientProfile(
    phoneNumber: "0987654321",
    email: "new-email@example.com",
    appName: nil,
    advertisingId: "updated-advertising-id"
)
TenMaxAdBeaconSDK.shared().updateClientProfile(updatedProfile)
```

### Data Persistence

The SDK automatically persists user profile data across app restarts. This ensures that user information is retained even when the app is killed and restarted.

#### Automatic Data Persistence

```swift
// First time - provide user data
let profile = ClientProfile(
    phoneNumber: "0912345678",
    email: "user@example.com",
    appName: "YourApp"
)

// After app restart - data is automatically restored
let profileAfterRestart = ClientProfile(appName: "YourApp")
// phoneNumber and email are automatically loaded from previous session
```

#### Automatic Advertising ID Retrieval

```swift
// When advertisingId is nil, SDK automatically retrieves from system if authorized
let profile = ClientProfile(
    phoneNumber: "0912345678",
    email: "user@example.com",
    appName: nil,
    advertisingId: nil  // SDK will auto-retrieve system IDFA if authorized
)

// Explicit advertisingId always takes precedence
let profileWithExplicitId = ClientProfile(
    phoneNumber: "0912345678",
    email: "user@example.com",
    appName: "YourApp",
    advertisingId: "explicit-id"  // Uses this value instead of system IDFA
)
```

#### Clearing Persisted Data

```swift
// Clear all persisted user data
ClientProfile.clearPersistedData()

// After clearing, create new profile with fresh data
let freshProfile = ClientProfile(
    phoneNumber: "new-phone",
    email: "new-email@example.com",
    appName: "YourApp"
)
```

### Creative Content Handling

When a beacon is detected, the SDK will automatically:

1. **Scan for Beacons**: Continuously scan for both iBeacons and custom beacons
2. **Fetch Creative Content**: Retrieve relevant advertising content based on beacon proximity
3. **Deliver Content**: Call your callback with the creative content
4. **Handle Notifications**: Optionally trigger local notifications

## Demo Application

The `demo` folder contains a complete demonstration application showing:

- SDK integration using XCFramework
- Permission management
- User profile configuration
- Real-time beacon detection
- Creative content display
- Notification handling

### Running the Demo

**Using Xcode**
1. Navigate to `demo`
2. Open `TenMaxBeaconPublicDemoApp.xcworkspace`
3. Select the appropriate scheme:
   - `TenMaxBeaconPublicDemoApp-Beta` for debug environment
   - `TenMaxBeaconPublicDemoApp-Release` for release environment
4. Build and run on a physical device (required for beacon functionality)

## Error Handling

The SDK provides comprehensive error handling through the `TenMaxAdBeaconError` class. Common error types include:

- **Permission Errors**: Location, Bluetooth, or Notification permissions denied
- **Configuration Errors**: SDK initialization, beacon settings, or API configuration issues
- **Network Errors**: Internet connectivity issues
- **Frequency Cap Exceeded**: Creative content blocked due to frequency limits
- **Beacon Errors**: Issues with beacon detection or processing

### Comprehensive Error Handling

```swift
class BeaconCallback: TenMaxAdBeaconCallback {

    func onInitialized() {
        print("SDK initialized successfully")
        // Start scanning after successful initialization
        TenMaxAdBeaconSDK.shared().start()
    }

    func onCreativeReceived(creative: TenMaxAdCreative) {
        print("Creative received with data: \(creative.data ?? "No data")")

        // Handle data navigation
        if let data = creative.data {
            handleData(data)
        }
    }

    func onError(error: TenMaxAdBeaconError) {
        print("SDK Error: \(error.message)")

        switch error.code {
        case .unauthorizedLocationPermission:
            showLocationPermissionAlert()

        case .locationPermissionNotAlways:
            showAlwaysLocationPermissionAlert()

        case .bluetoothDisabled:
            showBluetoothDisabledAlert()

        case .bluetoothPermissionDenied:
            showBluetoothPermissionAlert()

        case .unauthorizedNotificationPermission:
            showNotificationPermissionAlert()

        case .internetConnectionUnavailable:
            showOfflineMessage()

        case .frequencyCapExceeded:
            // This is normal behavior - creative was blocked due to frequency limits
            print("Creative blocked due to frequency capping")

        case .configurationError:
            // Handle configuration issues (Please contact with app_support@tenmax.io)
            print("Configuration error: Check SDK initialization and configuration")

        case .notFoundCreative:
            print("No creative content available for this beacon")

        case .invalidCreative:
            print("Invalid creative data received from server")

        default:
            showGenericErrorAlert(message: error.message)
        }
    }

    func onNotificationClicked(creative: TenMaxAdCreative) {
        print("Notification clicked with data: \(creative.data ?? ""), creativeId: \(creative.creativeId)")
        if let data = creative.data {
            handleData(data)
        }
    }

    // Helper methods for handling data and showing alerts
    private func handleData(_ data: String) {
        // Implement your data handling logic
        if let url = URL(string: data) {
            // Navigate to appropriate screen
            // UIApplication.shared.open(url)
        }
    }

    private func showLocationPermissionAlert() {
        // Show alert guiding user to enable location permission
    }

    // ... other helper methods
}
```

## Advanced Features

### Background Scanning

The SDK supports background beacon scanning when proper permissions are granted and background modes are configured in your app's Info.plist.

### Thread Safety

All SDK callbacks are automatically executed on the main thread, ensuring safe UI updates without additional threading considerations.

## System Requirements

- **iOS**: 12.0 or later
- **Swift**: 5.5 or later
- **Xcode**: 16.2.0 or later (recommended for latest features)
- **Deployment Target**: iOS 12.0+
- **Swift Tools Version**: 5.5 (as specified in Package.swift)

### Device Requirements

- **Bluetooth**: Bluetooth 4.0 (Bluetooth Low Energy) or later
- **Location Services**: Required for beacon detection
- **Background App Refresh**: Recommended for optimal background scanning
- **Device**: Physical iOS device (beacon functionality requires hardware)
- **Simulator Support**: Limited functionality on iOS Simulator (no actual beacon detection)

## Privacy and Data Handling

### Data Collection and Storage

The TenMax Beacon SDK collects and stores the following types of data:

#### Automatically Collected Data
- **Device Information**: Device model, system name and version
- **UUID**: Unique identifier generated locally and stored permanently
- **Advertising ID**: System advertising identifier (IDFA) when available and authorized

#### User-Provided Data
- **Phone Number**: Stored locally in UserDefaults when provided
- **Email Address**: Stored locally in UserDefaults when provided
- **App Name**: Stored locally in UserDefaults

### Data Persistence

- **Local Storage**: User profile data is stored locally using UserDefaults
- **Automatic Cleanup**: Data is automatically removed when the app is uninstalled
- **Manual Cleanup**: Use `ClientProfile.clearPersistedData()` to manually clear stored data

### Advertising ID Handling

- **iOS 14+ Compliance**: Automatically checks ATTrackingManager authorization status
- **Fallback Behavior**: When advertising ID is unavailable or unauthorized, SDK continues to function normally
- **User Control**: Respects user's tracking preferences set in iOS Settings

### Privacy Compliance

- **PrivacyInfo.xcprivacy**: Includes App Store privacy manifest
- **User Consent**: Obtain appropriate user consent before collecting personal information
- **Data Minimization**: Only collects data necessary for beacon functionality
- **Transparency**: All data collection is documented and transparent

### Best Practices

```swift
// Always obtain user consent before collecting personal data
func requestUserConsent() {
    // Your consent mechanism here
    if userConsentedToDataCollection {
        let profile = ClientProfile(
            phoneNumber: userPhoneNumber,
            email: userEmail,
            appName: nil  // Auto-detects from bundle info
        )
        // Initialize SDK with profile
    }
}

// Clear data when user withdraws consent
func handleConsentWithdrawal() {
    ClientProfile.clearPersistedData()
    TenMaxAdBeaconSDK.shared().stop()
}
```

## Apple Privacy Survey for TenMax SDK

iOS publisher should provide the information that data their apps collect, including the data collected by third-party SDKs. For your convenience, TenMax SDK provides the information on its data collection in the [Apple Privacy Survey for TenMax SDK](Privacy.md).

## Issues and Contact

If you have any issue when using TenMax Beacon SDK, please contact [app_support@tenmax.io](mailto:app_support@tenmax.io). We would help you as soon as possible.

## User Data Deletion Notice

For requests to delete the privacy data linked to users, please submit the request via [User Data Deletion Notice Form](https://forms.office.com/r/SnU40q6VmQ).

## License

TenMax
