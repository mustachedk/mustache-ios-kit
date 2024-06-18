#if canImport(UIKit)

import UIKit

public extension UILabel {
    
    func styleParagraph(lineHeightMultiple: CGFloat?, lineSpacing: CGFloat?, margin: CGFloat?, kern: CGFloat?) {
        
        let newParagraphStyle = NSMutableParagraphStyle()
        newParagraphStyle.alignment = self.textAlignment
        
        if let lineHeightMultiple {
            newParagraphStyle.lineHeightMultiple = lineHeightMultiple
        }
        if let lineSpacing {
            newParagraphStyle.lineSpacing = lineSpacing
        }
        if let margin {
            newParagraphStyle.firstLineHeadIndent = margin
            newParagraphStyle.headIndent = margin
            newParagraphStyle.tailIndent = -margin
        }
        
        if let attributedText, let currentParagraphStyle = attributedText.attribute(NSAttributedString.Key.paragraphStyle, at: 0, effectiveRange: nil) as? NSParagraphStyle {
            
            newParagraphStyle.setParagraphStyle(currentParagraphStyle)
            
            let attributedString = NSMutableAttributedString(attributedString: attributedText)
            let range = NSRange(location: 0, length: attributedString.length)
            
            if let kern {
                attributedString.addAttribute(.kern, value: kern, range: range)
            }
            attributedString.addAttribute(.paragraphStyle, value: newParagraphStyle, range: range)
            
            self.attributedText = attributedString
            
        } else if let text {
            
            let attributedString = NSMutableAttributedString(string: text)
            let range = NSRange(location: 0, length: attributedString.length)
            
            if let kern {
                attributedString.addAttribute(.kern, value: kern, range: range)
            }
            attributedString.addAttribute(.paragraphStyle, value: newParagraphStyle, range: range)
            
            self.attributedText = attributedString
            
        }
    }
    
}

public extension NSMutableParagraphStyle {
    
    convenience init(lineSpacing: CGFloat? = nil,
                     paragraphSpacing: CGFloat? = nil,
                     alignment: NSTextAlignment? = nil,
                     firstLineHeadIndent: CGFloat? = nil,
                     headIndent: CGFloat? = nil,
                     tailIndent: CGFloat? = nil,
                     lineBreakMode: NSLineBreakMode? = nil,
                     minimumLineHeight: CGFloat? = nil,
                     maximumLineHeight: CGFloat? = nil,
                     baseWritingDirection: NSWritingDirection? = nil,
                     lineHeightMultiple: CGFloat? = nil,
                     paragraphSpacingBefore: CGFloat? = nil,
                     hyphenationFactor: Float? = nil,
                     usesDefaultHyphenation: Bool? = nil,
                     tabStops: [NSTextTab]? = nil,
                     defaultTabInterval: CGFloat? = nil,
                     allowsDefaultTighteningForTruncation: Bool? = nil,
                     lineBreakStrategy: LineBreakStrategy? = nil,
                     textLists:  [NSTextList]? = nil) {
        self.init()
        
        if let lineSpacing {
            self.lineSpacing = lineSpacing
        }
        if let paragraphSpacing {
            self.paragraphSpacing = paragraphSpacing
        }
        if let alignment {
            self.alignment = alignment
        }
        if let firstLineHeadIndent {
            self.firstLineHeadIndent = firstLineHeadIndent
        }
        if let headIndent {
            self.headIndent = headIndent
        }
        if let tailIndent {
            self.tailIndent = tailIndent
        }
        if let lineBreakMode {
            self.lineBreakMode = lineBreakMode
        }
        if let minimumLineHeight {
            self.minimumLineHeight = minimumLineHeight
        }
        if let maximumLineHeight {
            self.maximumLineHeight = maximumLineHeight
        }
        if let baseWritingDirection {
            self.baseWritingDirection = baseWritingDirection
        }
        if let lineHeightMultiple {
            self.lineHeightMultiple = lineHeightMultiple
        }
        if let paragraphSpacingBefore {
            self.paragraphSpacingBefore = paragraphSpacingBefore
        }
        if let hyphenationFactor {
            self.hyphenationFactor = hyphenationFactor
        }
        if let usesDefaultHyphenation {
            if #available(iOS 15.0, *) {
                self.usesDefaultHyphenation = usesDefaultHyphenation
            }
        }
        if let tabStops {
            self.tabStops = tabStops
        }
        if let defaultTabInterval {
            self.defaultTabInterval = defaultTabInterval
        }
        if let allowsDefaultTighteningForTruncation {
            self.allowsDefaultTighteningForTruncation = allowsDefaultTighteningForTruncation
        }
        if let lineBreakStrategy {
            self.lineBreakStrategy = lineBreakStrategy
        }
        if let textLists {
            self.textLists = textLists
        }
    }
    
}

#endif
