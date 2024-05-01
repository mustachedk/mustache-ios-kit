
import Foundation

public extension String {
    
    /// Uses NSDataDetector to detect if string is valid email
    var isEmail: Bool {
        var email = self.trimmingCharacters(in: .whitespacesAndNewlines)
        
        let types: NSTextCheckingResult.CheckingType = .link
        
        do {
            let detector = try NSDataDetector(types: types.rawValue)
            let matches = detector.matches(in: email, options: [], range: NSRange(location: 0, length: email.utf16.count))
            
            for match in matches {
                if match.resultType == .link,
                   let url = match.url,
                   url.scheme == "mailto",
                   match.range.length == email.utf16.count { // Ensures the entire string is a valid email
                    return true
                }
            }
        } catch {
            print("Invalid detector.")
        }
        return false
    }
    
}
