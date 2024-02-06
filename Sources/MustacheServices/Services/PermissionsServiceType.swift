
import Foundation
import CoreLocation
import CoreBluetooth
import AVFoundation
import UserNotifications
import MustacheFoundation
import Combine

@available(iOS 14.0, macOS 10.15, *)
public protocol PermissionsServiceType {
    
    var isLocationAllowed: Bool { get }
    
    var locationStatusPublisher: AnyPublisher<CLAuthorizationStatus, Never> { get }
    
    var isNotificationAllowed: Bool { get }
    
    var isCameraAllowed: Bool { get }
    
    var isBlueToothAllowed: Bool { get }
    
    func locationPermission() async throws -> Bool
    
    func notificationPermission() async throws -> Bool
    
    func cameraRecordPermission() async throws -> Bool
    
    func bluetoothPermission() async throws -> Bool
}

@available(iOS 14.0, macOS 15, *)
public class PermissionsService: NSObject, PermissionsServiceType {
    
    private var locationAuthorizationStatus: CLAuthorizationStatus {
        return self.locationManager.authorizationStatus
    }
    
#if os(iOS)
    public var isLocationAllowed: Bool {
        let authorizationStatus = self.locationAuthorizationStatus
        return (authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways) && CLLocationManager.locationServicesEnabled()
    }
#elseif os(macOS)
    public var isLocationAllowed: Bool {
        let authorizationStatus = self.locationAuthorizationStatus
        return authorizationStatus == .authorizedAlways && CLLocationManager.locationServicesEnabled()
    }
#endif
    
    private lazy var locationStatusSubject: CurrentValueSubject<CLAuthorizationStatus, Never> = {
        let initial = self.locationManager.authorizationStatus
        let subject = CurrentValueSubject<CLAuthorizationStatus, Never>(initial)
        return subject
    }()
    
    public var locationStatusPublisher: AnyPublisher<CLAuthorizationStatus, Never> {
        return self.locationStatusSubject.eraseToAnyPublisher()
    }
    
    @UserDefault("isNotificationAllowed", defaultValue: false)
    public var isNotificationAllowed: Bool
    
    public var isCameraAllowed: Bool {
        return AVCaptureDevice.authorizationStatus(for: .video) != .authorized
    }
    
    public var isBlueToothAllowed: Bool {
        return CBCentralManager.authorization == .allowedAlways
    }
    
    private var locationContinuation: CheckedContinuation<Bool, Error>?
    private lazy var locationManager: CLLocationManager = { return CLLocationManager() }()
    
    private var peripheralContinuation: CheckedContinuation<Bool, Error>?
    private lazy var peripheralManager: CBPeripheralManager = { return CBPeripheralManager() }()
    
    public func locationPermission() async throws -> Bool {
        return try await withCheckedThrowingContinuation { [weak self] continuation in
            guard let self = self else { return }
            self.locationContinuation = continuation
            
            DispatchQueue.main.async {
                self.locationManager.delegate = self
                self.locationManager.requestAlwaysAuthorization()
                
                Timer.scheduledTimer(timeInterval: 30,
                                     target: self,
                                     selector: #selector(PermissionsService.locationManagerTimeout),
                                     userInfo: nil,
                                     repeats: false)
                
            }
        }
    }
    
    public func notificationPermission() async throws -> Bool {
        let result = try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound])
        self.isNotificationAllowed = result
        return result
    }
    
    public func cameraRecordPermission() async throws -> Bool {
        return await AVCaptureDevice.requestAccess(for: .video)
    }
    
    public func bluetoothPermission() async throws -> Bool {
        return try await withCheckedThrowingContinuation { [weak self] continuation in
            guard let self = self else { return }
            self.peripheralContinuation = continuation
            
            DispatchQueue.main.async {
                self.peripheralManager.delegate = self
                
                Timer.scheduledTimer(timeInterval: 30,
                                     target: self,
                                     selector: #selector(PermissionsService.peripheralManagerTimeout),
                                     userInfo: nil,
                                     repeats: false)
            }
        }
    }
    
    deinit {
        debugPrint("deinit \(self)")
    }
}

@available(iOS 14.0, macOS 15, *)
extension PermissionsService: CLLocationManagerDelegate {
    
    @objc public func locationManagerTimeout() {
        self.locationContinuation?.resume(returning: false)
        self.locationContinuation = nil
    }
    
    public func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
            case .notDetermined, .restricted, .denied:
                self.locationContinuation?.resume(returning: false)
            case .authorizedAlways, .authorizedWhenInUse:
                self.locationContinuation?.resume(returning: true)
            @unknown default:
                self.locationContinuation?.resume(returning: false)
        }
        self.locationContinuation = nil
        self.locationStatusSubject.value = manager.authorizationStatus
    }
    
    public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
            case .notDetermined, .restricted, .denied:
                self.locationContinuation?.resume(returning: false)
            case .authorizedAlways, .authorizedWhenInUse:
                self.locationContinuation?.resume(returning: true)
            @unknown default:
                self.locationContinuation?.resume(returning: false)
        }
        self.locationContinuation = nil
    }
    
    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        if let error = error as? CLError, error.code == .denied {
            self.locationContinuation?.resume(throwing: error)
        }
        self.locationContinuation = nil
    }
    
}

@available(iOS 14.0, macOS 15, *)
extension PermissionsService: CBPeripheralManagerDelegate {
    
    @objc public func peripheralManagerTimeout() {
        self.peripheralContinuation?.resume(returning: false)
        self.peripheralContinuation = nil
    }
    
    public func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        guard peripheral.state != .unknown else { return }
        switch CBCentralManager.authorization {
            case .notDetermined, .restricted, .denied:
                self.peripheralContinuation?.resume(returning: false)
            case .allowedAlways:
                self.peripheralContinuation?.resume(returning: true)
            @unknown default:
                self.peripheralContinuation?.resume(returning: false)
        }
        self.peripheralContinuation = nil
    }
}

public extension CLAuthorizationStatus {
    
    var authorized: Bool {
        switch self {
            case .authorizedAlways, .authorizedWhenInUse:
                return true
            default:
                return false
        }
    }
}
