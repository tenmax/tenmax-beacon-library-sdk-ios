import UIKit
import CoreLocation
import UserNotifications
import AppTrackingTransparency
import AdSupport

protocol PermissionManagerDelegate: AnyObject {
    func permissionManager(_ manager: PermissionManager, didUpdateAdvertisingId advertisingId: String?)
    func permissionManager(_ manager: PermissionManager, didCompletePermissionRequests: Void)
    func permissionManager(_ manager: PermissionManager, didLogMessage message: String)
}

class PermissionManager: NSObject {
    weak var delegate: PermissionManagerDelegate?
    
    private let locationManager = CLLocationManager()
    private var advertisingId: String?
    
    override init() {
        super.init()
        setupLocationManager()
    }
    
    private func setupLocationManager() {
        locationManager.delegate = self
    }
    
    func requestAllPermissions() {
        log("Starting permission requests...")
        if #available(iOS 13.0, *) {
            Task {
                await requestPermissionsSequentially()
            }
        } else {
            requestNotificationPermission()
            requestLocationPermission()
        }
    }
    
    @available(iOS 13.0, *)
    private func requestPermissionsSequentially() async {
        await requestNotificationPermissionAsync()
        
        try? await Task.sleep(nanoseconds: 500_000_000)
        
        await requestLocationPermissionAsync()
        
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        
        await requestIDFAPermissionAsync()
        
        await MainActor.run {
            self.delegate?.permissionManager(self, didCompletePermissionRequests: ())
        }
    }
    
    @available(iOS 13.0, *)
    private func requestNotificationPermissionAsync() async {
        log("Requesting notification permission...")
        let (granted, error) = await NotificationHelper.shared.requestNotificationPermission()
        
        await MainActor.run {
            if granted {
                self.log("Notification permission granted")
            } else if let error = error {
                self.log("Notification permission error: \(error.localizedDescription)")
            } else {
                self.log("Notification permission denied")
            }
        }
    }
    
    private func requestNotificationPermission() {
        log("Requesting notification permission...")
        NotificationHelper.shared.requestNotificationPermission { granted, error in
            DispatchQueue.main.async {
                if granted {
                    self.log("Notification permission granted")
                } else if let error = error {
                    self.log("Notification permission error: \(error.localizedDescription)")
                } else {
                    self.log("Notification permission denied")
                }
                self.checkPermissions()
            }
        }
    }
    
    func checkPermissions() {
        let locationStatus = CLLocationManager.authorizationStatus()
        let locationAuthorized = (locationStatus == .authorizedAlways || locationStatus == .authorizedWhenInUse)

        NotificationHelper.shared.checkNotificationPermission { authorized in
            DispatchQueue.main.async {
                self.log("Location permission: \(locationAuthorized ? "Authorized" : "Unauthorized")")
                self.log("Notification permission: \(authorized ? "Authorized" : "Unauthorized")")
            }
        }
    }
    
    @available(iOS 13.0, *)
    private func requestLocationPermissionAsync() async {
        let currentStatus = CLLocationManager.authorizationStatus()

        await MainActor.run {
            switch currentStatus {
            case .notDetermined:
                self.log("Requesting location permission (When In Use)...")
                self.locationManager.requestWhenInUseAuthorization()
            case .authorizedWhenInUse:
                self.log("Requesting location permission (Always)...")
                self.locationManager.requestAlwaysAuthorization()
            case .denied, .restricted:
                self.log("Location permission denied, please enable in Settings")
            case .authorizedAlways:
                self.log("Location permission authorized (Always)")
            @unknown default:
                self.log("Unknown location permission status")
            }
        }

        if currentStatus == .notDetermined || currentStatus == .authorizedWhenInUse {
            await waitForLocationPermissionChange()
        }
    }
    
    @available(iOS 13.0, *)
    private func waitForLocationPermissionChange() async {
        return await withCheckedContinuation { continuation in
            var isResumed = false
            var observer: NSObjectProtocol?
            
            let resumeOnce = {
                guard !isResumed else { return }
                isResumed = true
                if let observer = observer {
                    NotificationCenter.default.removeObserver(observer)
                }
                continuation.resume()
            }
            
            observer = NotificationCenter.default.addObserver(
                forName: NSNotification.Name("LocationPermissionChanged"),
                object: nil,
                queue: .main
            ) { _ in
                resumeOnce()
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 10.0) {
                resumeOnce()
            }
        }
    }

    private func requestLocationPermission() {
        let currentStatus = CLLocationManager.authorizationStatus()

        switch currentStatus {
        case .notDetermined:
            log("Requesting location permission (When In Use)...")
            locationManager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse:
            log("Requesting location permission (Always)...")
            locationManager.requestAlwaysAuthorization()
        case .denied, .restricted:
            log("Location permission denied, please enable in Settings")
        case .authorizedAlways:
            log("Location permission authorized (Always)")
        @unknown default:
            log("Unknown location permission status")
        }
    }
    
    @available(iOS 13.0, *)
    private func requestIDFAPermissionAsync() async {
        if #available(iOS 14, *) {
            let currentStatus = ATTrackingManager.trackingAuthorizationStatus

            await MainActor.run {
                self.log("Current IDFA status: \(self.idfaStatusString(currentStatus))")

                let appState = UIApplication.shared.applicationState
                self.log("App state: \(appState == .active ? "active" : appState == .background ? "background" : "inactive")")
            }

            if currentStatus == .notDetermined {
                await MainActor.run {
                    self.log("Requesting IDFA permission...")
                }

                await MainActor.run {
                    guard UIApplication.shared.applicationState == .active else {
                        self.log("App is not active, delaying IDFA request")
                        return
                    }
                }

                let status = await ATTrackingManager.requestTrackingAuthorization()

                await MainActor.run {
                    self.log("IDFA permission result: \(self.idfaStatusString(status))")
                    switch status {
                    case .authorized:
                        self.log("IDFA permission authorized")
                        self.advertisingId = ASIdentifierManager.shared().advertisingIdentifier.uuidString
                        self.log("IDFA value: \(self.advertisingId ?? "nil")")
                    case .denied:
                        self.log("IDFA permission denied")
                    case .restricted:
                        self.log("IDFA permission restricted - may be due to parental controls or enterprise restrictions")
                    case .notDetermined:
                        self.log("IDFA permission still not determined - this may indicate:")
                        self.log("1. System dialog was not shown")
                        self.log("2. User dismissed dialog without choosing")
                        self.log("3. System restrictions prevent the dialog")
                    @unknown default:
                        self.log("Unknown IDFA permission status")
                    }
                    self.delegate?.permissionManager(self, didUpdateAdvertisingId: self.advertisingId)
                }
            } else {
                await MainActor.run {
                    self.log("IDFA permission already determined: \(self.idfaStatusString(currentStatus))")
                    if currentStatus == .authorized {
                        self.advertisingId = ASIdentifierManager.shared().advertisingIdentifier.uuidString
                        self.log("IDFA value: \(self.advertisingId ?? "nil")")
                    }
                    self.delegate?.permissionManager(self, didUpdateAdvertisingId: self.advertisingId)
                }
            }
        } else {
            await MainActor.run {
                self.log("iOS version below 14, getting IDFA directly")
                self.advertisingId = ASIdentifierManager.shared().advertisingIdentifier.uuidString
                self.log("IDFA value: \(self.advertisingId ?? "nil")")
                self.delegate?.permissionManager(self, didUpdateAdvertisingId: self.advertisingId)
            }
        }
    }

    private func requestIDFAPermission() {
        if #available(iOS 14, *) {
            log("Requesting IDFA permission...")
            ATTrackingManager.requestTrackingAuthorization { [weak self] status in
                DispatchQueue.main.async {
                    guard let self = self else { return }
                    switch status {
                    case .authorized:
                        self.log("IDFA permission authorized")
                        self.advertisingId = ASIdentifierManager.shared().advertisingIdentifier.uuidString
                    case .denied:
                        self.log("IDFA permission denied")
                    case .restricted:
                        self.log("IDFA permission restricted")
                    case .notDetermined:
                        self.log("IDFA permission not determined")
                    @unknown default:
                        self.log("Unknown IDFA permission status")
                    }
                    self.delegate?.permissionManager(self, didUpdateAdvertisingId: self.advertisingId)
                }
            }
        } else {
            log("iOS version below 14, getting IDFA directly")
            advertisingId = ASIdentifierManager.shared().advertisingIdentifier.uuidString
            delegate?.permissionManager(self, didUpdateAdvertisingId: advertisingId)
        }
    }

    @available(iOS 14, *)
    private func idfaStatusString(_ status: ATTrackingManager.AuthorizationStatus) -> String {
        switch status {
        case .authorized:
            return "authorized"
        case .denied:
            return "denied"
        case .restricted:
            return "restricted"
        case .notDetermined:
            return "notDetermined"
        @unknown default:
            return "unknown"
        }
    }

    func getAdvertisingId() -> String? {
        return advertisingId
    }

    private func log(_ message: String) {
        delegate?.permissionManager(self, didLogMessage: message)
    }
}

// MARK: - CLLocationManagerDelegate
extension PermissionManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined:
            log("Location permission status: Not determined")
        case .authorizedWhenInUse:
            log("Location permission authorized (When In Use), requesting Always permission...")
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.locationManager.requestAlwaysAuthorization()
            }
        case .authorizedAlways:
            log("Location permission authorized (Always)")
            if #available(iOS 13.0, *) {
                NotificationCenter.default.post(name: NSNotification.Name("LocationPermissionChanged"), object: nil)
            } else {
                requestIDFAPermission()
            }
        case .denied:
            log("Location permission denied")
            if #available(iOS 13.0, *) {
                NotificationCenter.default.post(name: NSNotification.Name("LocationPermissionChanged"), object: nil)
            } else {
                requestIDFAPermission()
            }
        case .restricted:
            log("Location permission restricted")
            if #available(iOS 13.0, *) {
                NotificationCenter.default.post(name: NSNotification.Name("LocationPermissionChanged"), object: nil)
            } else {
                requestIDFAPermission()
            }
        @unknown default:
            log("Unknown location permission status")
            if #available(iOS 13.0, *) {
                NotificationCenter.default.post(name: NSNotification.Name("LocationPermissionChanged"), object: nil)
            } else {
                requestIDFAPermission()
            }
        }
    }
}
