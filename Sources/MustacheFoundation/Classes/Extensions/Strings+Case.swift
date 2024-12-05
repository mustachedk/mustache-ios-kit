
import Foundation

fileprivate let badChars = CharacterSet.alphanumerics.inverted

public extension String {
    
    var uppercaseFirst: String {
        return prefix(1).uppercased() + dropFirst()
    }
    
    var lowercaseFirst: String {
        return prefix(1).lowercased() + dropFirst()
    }
    
    var camelize: String {
        guard !isEmpty else { return "" }
        
        let parts = self.components(separatedBy: badChars)
        
        let first = String(describing: parts.first!).lowercaseFirst
        let rest = parts.dropFirst().map({ String($0).uppercaseFirst })
        
        return ([first] + rest).joined(separator: "")
    }
    
    var snakeCase: String {
        let pattern = "([a-z0-9])([A-Z])"
        let regex = try? NSRegularExpression(pattern: pattern, options: [])
        let range = NSRange(location: 0, length: count)
        return regex?.stringByReplacingMatches(in: self, options: [], range: range, withTemplate: "$1_$2").lowercased() ?? self
    }
}
