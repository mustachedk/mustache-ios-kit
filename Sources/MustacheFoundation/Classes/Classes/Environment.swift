import Foundation

public struct Environment {

    public static var config: Configuration {
        guard let info = infoForKey("ENVIRONMENT_CONFIGURATION") else {
            fatalError("ENVIRONMENT_CONFIGURATION not present in plist")
        }
        guard let config = Configuration(rawValue: info) else {
            fatalError("illegal value for ENVIRONMENT_CONFIGURATION \(info)")
        }
        return config
    }
    
    public static var clientId: String? {
        let info = infoForKey("ENVIRONMENT_CLIENT_ID")
        return info
    }
    
    public static var clientSecret: String? {
        let info = infoForKey("ENVIRONMENT_CLIENT_SECRET")
        return info
    }
    
    public static var isSimulator: Bool {
        #if targetEnvironment(simulator)
            return true
        #else
            return false
        #endif
    }

}

public enum Configuration: String {
    case development, staging, production
}

extension Environment {
    
    private static let isTestFlight = Bundle.main.appStoreReceiptURL?.lastPathComponent == "sandboxReceipt"
    
    // Assumes that the DEBUG flag is set
    static var isDebug: Bool {
#if DEBUG
        return true
#else
        return false
#endif
    }
    
    public static var deployment: Deployment {
        if self.isDebug {
            return .debug
        } else if isTestFlight {
            return .testFlight
        } else {
            return .appStore
        }
    }
}

public enum Deployment {
    case debug
    case testFlight
    case appStore
}

public func infoForKey(_ key: String) -> String? {
    return (Bundle.main.infoDictionary?[key] as? String)?
        .replacingOccurrences(of: "\\", with: "")
        .trimmingCharacters(in: .whitespacesAndNewlines)
}

public func pListValue<T>(_ key: String, name: String) -> T? {
    guard let plistPath = Bundle.main.path(forResource: name, ofType: "plist") else { return nil }
    guard let plistData = FileManager.default.contents(atPath: plistPath) else { return nil }
    var format = PropertyListSerialization.PropertyListFormat.xml
    guard let plistDict = try? PropertyListSerialization.propertyList(from: plistData,
                                                                      options: .mutableContainersAndLeaves,
                                                                      format: &format) as? [String: AnyObject] else { return nil }
    let myValue = plistDict[key] as? T
    return myValue
}
