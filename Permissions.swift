import Foundation
import AVFoundation
import UserNotifications

enum PermissionType {
    case camera
    case notifications
}

enum PermissionStatus: Int {
    case unknown
    case denied
    case granted
}

class Permissions {
    
    // MARK: - Properties
    
    lazy var notificationOptions: UNAuthorizationOptions = [.alert, .sound, .badge]
    
    // MARK: - Getters
    
    subscript(type: PermissionType) -> PermissionStatus {
        get {
            return self.status(for: type)
        }
    }
    
    func status(`for` type: PermissionType) -> PermissionStatus {
        let status: PermissionStatus
        
        switch type {
        case .camera:
            status = self.cameraStatus
        case .notifications:
            status = self.notificationsStatus
        }
        
        return status
    }
    
    private var cameraStatus: PermissionStatus {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        switch status {
        case .authorized:
            return .granted
        case .denied, .restricted:
            return .denied
        case .notDetermined:
            return .unknown
        }
    }
    
    private var notificationsStatus: PermissionStatus {
        var notificationStatus: UNAuthorizationStatus?
        let semaphore = DispatchSemaphore(value: 0)
        UNUserNotificationCenter.current().getNotificationSettings() { settings in
            notificationStatus = settings.authorizationStatus
            semaphore.signal()
        }
        _ = semaphore.wait(timeout: .distantFuture)
        
        return PermissionStatus(rawValue: notificationStatus!.rawValue)!
    }
    
    // MARK: - Requests
    
    func request(`for` type: PermissionType, completion: @escaping (PermissionStatus) -> Void) {
        func callback(_ granted: Bool) {
            DispatchQueue.main.async {
                completion(granted ? .granted : .denied)
            }
        }
        
        switch type {
        case .camera:
            self.requestCameraAccess(callback)
        case .notifications:
            self.requestNotificationsAccess(callback)
        }
    }
    
    private func requestCameraAccess(_ completion: @escaping (Bool) -> Void) {
        AVCaptureDevice.requestAccess(for: .video, completionHandler: completion)
    }
    
    private func requestNotificationsAccess(_ completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(options: self.notificationOptions) { granted, _ in
            completion(granted)
        }
    }
    
}
