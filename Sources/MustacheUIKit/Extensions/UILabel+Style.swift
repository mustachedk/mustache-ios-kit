#if canImport(UIKit)

import UIKit

public extension UILabel {
    
    func styleParagraph(lineHeightMultiple: CGFloat = 0.0, lineSpacing: CGFloat = 0.0, kern: CGFloat = 0) {
        guard let text = self.text else { return }

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = self.textAlignment
        paragraphStyle.lineHeightMultiple = lineHeightMultiple
        paragraphStyle.lineSpacing = lineSpacing

        let attributedString:NSMutableAttributedString
        if let attributedText = self.attributedText {
            attributedString = NSMutableAttributedString(attributedString: attributedText)
        } else {
            attributedString = NSMutableAttributedString(string: text)
        }
        
        let range = NSMakeRange(0, attributedString.length)
        attributedString.addAttribute(.kern, value: kern, range: range)
        attributedString.addAttribute(.paragraphStyle, value:paragraphStyle, range: range)
        self.attributedText = attributedString
    }
    
}

#endif
