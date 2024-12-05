
import Foundation

public extension String {
    
    /// Uses NSDataDetector to detect if string is valid email
    var isEmail: Bool {
        var email = self.trimmingCharacters(in: .whitespacesAndNewlines)
        
        let types: NSTextCheckingResult.CheckingType = .link
        
        do {
            let detector = try NSDataDetector(types: types.rawValue)
            let matches = detector.matches(in: email, options: [], range: NSRange(location: 0, length: email.utf16.count))
            guard matches.count == 1, let match = matches.first else { return false }
            
            guard match.resultType == .link,
                  let url = match.url,
                  url.scheme == "mailto",
                  match.range.length == email.utf16.count
            else { return false }
            
        } catch {
            print("Invalid detector.")
        }
        return true
    }
    
}
