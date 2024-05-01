
import Foundation

public extension String {
    
    /// Uses NSDataDetector to detect if string is valid email
    var isEmail: Bool {
        let email = self.trimmingCharacters(in: .whitespacesAndNewlines)
        let emailDetector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
        let range = NSRange(email.startIndex...email.endIndex, in: email)
        let matches = emailDetector?.matches(in: email, options: [], range: range)
        guard matches?.count == 1, let match = matches?.first else { return false }
        
        guard match.range == range else { return false }
        guard match.url?.scheme == "mailto" else { return false }
        
        return true
    }
    
}
