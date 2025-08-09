import UIKit
import TenMaxBeaconSDK

class AppBeaconManager {
    static let shared = AppBeaconManager()

    private var isInitialized = false
    private var advertisingId: String?
    private var rootNavigationController: UINavigationController?
    private var phoneNumber: String?
    private var email: String?

    private init() {}
    
    func initialize(with navigationController: UINavigationController?) {
        self.rootNavigationController = navigationController
        
        if !isInitialized {
            setupBeaconSDK()
        }
    }
    
    func updateAdvertisingId(_ advertisingId: String?) {
        self.advertisingId = advertisingId

        if !isInitialized {
            setupBeaconSDK()
        } else {
            updateClientProfile()
        }
    }

    func updateClientInfo(phoneNumber: String?, email: String?) {
        self.phoneNumber = phoneNumber
        self.email = email

        if isInitialized {
            updateClientProfile()
        }
    }
    
    private var appName: String {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String
            ?? Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String
            ?? "Beacon Demo"
    }
    
    private func setupBeaconSDK() {
        let clientProfile = ClientProfile(
            phoneNumber: phoneNumber,
            email: email,
            appName: appName,
            advertisingId: advertisingId
        )

        TenMaxAdBeaconSDK.shared().initiate(
            clientProfile: clientProfile,
            callback: self,
            environment: .stage
        )

        isInitialized = true
    }
    
    private func updateClientProfile() {
        let clientProfile = ClientProfile(
            phoneNumber: phoneNumber,
            email: email,
            appName: appName,
            advertisingId: advertisingId
        )

        TenMaxAdBeaconSDK.shared().updateClientProfile(clientProfile)
    }
    
    private func log(_ message: String) {
        print("AppBeaconManager: \(message)")
    }
}

// MARK: - TenMaxAdBeaconCallback
extension AppBeaconManager: TenMaxAdBeaconCallback {
    func onCreativeReceived(creative: TenMaxAdCreative) {
        log("Creative content received")
    }
    
    func onError(error: TenMaxAdBeaconError) {
        log("Error: \(error.message)")
    }
    
    func onInitialized() {
        log("SDK initialized successfully")
        autoStartScanning()
    }
    
    func onNotificationClicked(creative: TenMaxAdCreative) {
        log("Notification clicked: \(creative.data ?? ""), creativeId: \(creative.creativeId)")

        let congratulationsViewController = CongratulationsViewController(deeplink: creative.data ?? "", creativeId: creative.creativeId)
        rootNavigationController?.pushViewController(congratulationsViewController, animated: true)
    }
    
    private func autoStartScanning() {
        TenMaxAdBeaconSDK.shared().start()
        log("Auto-started scanning for Beacons after SDK initialization")
    }
}
