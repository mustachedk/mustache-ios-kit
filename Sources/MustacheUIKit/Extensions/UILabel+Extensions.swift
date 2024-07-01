#if canImport(UIKit)

import UIKit

public extension UILabel {

    /// The text of the UILabel or an empty text
    var safeText: String { return self.text ?? "" }

    /// Is the labels text larger than available frame
    var isTruncated: Bool {
        guard let labelText = text else { return false }
        let size = CGSize(width: frame.size.width, height: .greatestFiniteMagnitude)
        let string = (labelText as NSString)
        let labelTextSize = string.boundingRect(with: size, options: .usesLineFragmentOrigin, attributes: [.font: font as Any], context: nil).size
        return labelTextSize.height > bounds.size.height
    }

    /// The max number of lines this label will be if max lines is set to 0
    var maxLines: Int {
        let maxSize = CGSize(width: frame.size.width, height: CGFloat(Float.infinity))
        let charSize = font.lineHeight
        let text = (self.text ?? "") as NSString
        let textSize = text.boundingRect(with: maxSize, options: .usesLineFragmentOrigin, attributes: [.font: font as Any], context: nil)
        let lines = textSize.height / charSize
        let linesRounded = Int(ceil(lines))
        return linesRounded
    }

    convenience init(string: String, font: UIFont, color: UIColor) {
        self.init()
        self.text = string
        self.font = font
        self.textColor = color
        self.sizeToFit()
    }

    /**
    Animates the font change for a UILabel

    - parameters:
        - font: UIFont
        - duration: TimeInterval
    */
    func animate(font: UIFont, duration: TimeInterval) {

        if self.font.fontName == font.fontName && self.font.pointSize == font.pointSize { return }
        // let oldFrame = frame
        let labelScale = self.font.pointSize / font.pointSize
        self.font = font
        let oldTransform = transform
        self.transform = transform.scaledBy(x: labelScale, y: labelScale)
        // let newOrigin = frame.origin
        // frame.origin = oldFrame.origin // only for left aligned text
        // frame.origin = CGPoint(x: oldFrame.origin.x + oldFrame.width - frame.width, y: oldFrame.origin.y) // only for right aligned text
        self.setNeedsUpdateConstraints()
        UIView.animate(withDuration: duration) {
            //L self.frame.origin = newOrigin
            self.transform = oldTransform
            self.layoutIfNeeded()
        }
    }

    func slideFont(with newFont: UIFont, to direction: UIRectEdge = .right, duration: TimeInterval = 0.3) {

        guard [UIRectEdge.left, UIRectEdge.right].contains(direction), duration > 0, let text = self.text, text.count > 0 else { return }

        let letterDuration: TimeInterval = duration / text.count.double

        let oldFont = self.font

        if direction == .right {
            DispatchQueue.main.async { [text] in

                for index in 0..<(text.count - 1) {

                    let delay = (index.double * letterDuration * 1000).int

                    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(delay)) {

                        let startString = text[0...index]
                        let endString = text[(index + 1)...text.count - 1]

                        let start = NSMutableAttributedString(string: startString,
                                                              attributes: [NSAttributedString.Key.font: newFont as Any,
                                                                           NSAttributedString.Key.foregroundColor: UIColor.black as Any])
                        let end = NSMutableAttributedString(string:
                                                            endString, attributes: [NSAttributedString.Key.font: oldFont as Any,
                                                                                    NSAttributedString.Key.foregroundColor: UIColor.black as Any])
                        start.append(end)

                        self.attributedText = start
                    }
                }
            }
        } else if direction == .left {

            DispatchQueue.main.async { [text] in

                for index in 0..<(text.count - 1) {

                    let delay = (index.double * letterDuration * 1000).int

                    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(delay)) {

                        let startString = text[0...(text.count - 1 - index - 1)]
                        let endString = text[(text.count - 1 - index)...text.count - 1]

                        let start = NSMutableAttributedString(string: startString,
                                                              attributes: [NSAttributedString.Key.font: oldFont as Any,
                                                                           NSAttributedString.Key.foregroundColor: UIColor.black as Any])
                        let end = NSMutableAttributedString(string: endString,
                                                            attributes: [NSAttributedString.Key.font: newFont as Any,
                                                                         NSAttributedString.Key.foregroundColor: UIColor.black as Any])
                        start.append(end)
                        //
                        self.attributedText = start
                    }
                }
            }
        }

        let delay = (duration * 1000).int
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(delay)) {
            self.attributedText = nil
            self.text = text
            self.font = newFont
        }

    }
}
#endif
