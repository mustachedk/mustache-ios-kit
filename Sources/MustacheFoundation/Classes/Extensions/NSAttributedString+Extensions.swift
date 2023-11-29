
// Credit https://stackoverflow.com/a/50064887/1366083

import Foundation

public extension NSMutableAttributedString {
    
    func set(linkString: String) {
        guard !linkString.isEmpty else { return }
        let scanner = Scanner(string: linkString)
        
        repeat {
            
            let textBeforeLink = scanner.scanUpToString("<a href=\"") ?? ""
            
            _ = scanner.scanString("<a href=\"")
            let linkURL = scanner.scanUpToString("\">") ?? ""
            
            _ = scanner.scanString("\">")
            let linkText = scanner.scanUpToString("</a>") ?? ""
            _ = scanner.scanString("</a>")
            
            self.append(.init(string: textBeforeLink))
            
            if !linkText.isEmpty {
                let link = NSMutableAttributedString(string: linkText)
                let foundRange = NSRange(location: 0, length: link.length)
                link.addAttribute(.link, value: linkURL, range: foundRange)
                link.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: foundRange)
                self.append(link)
                self.append(.init(string: " "))
            }
            
        } while !scanner.isAtEnd
        
    }
    
    func addAttribute(_ name: NSAttributedString.Key, value: Any) {
        let full = NSRange(location: 0, length: self.length)
        self.addAttribute(name, value: value, range: full)
    }
    
}
