#if canImport(UIKit)
import UIKit

public extension UIDevice {
    
    var modelIdentifier: String? {
        if let simulatorModelIdentifier = ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] {
            return simulatorModelIdentifier
        }
        var sysinfo = utsname()
        uname(&sysinfo) // ignore return value
        let machine = Data(bytes: &sysinfo.machine, count: Int(_SYS_NAMELEN))
        let modelIdentifier = String(bytes: machine, encoding: .ascii)?.trimmingCharacters(in: .controlCharacters)
        return modelIdentifier
    }
    
}
#endif
