#if canImport(UIKit)
import Foundation
import UIKit

public extension String {

    var image: UIImage? { return UIImage(named: self) }

    func height(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
        return self.size(withConstrainedHeight: .greatestFiniteMagnitude, constrainedWidth: width, font: font).height
    }

    func width(withConstrainedHeight height: CGFloat, font: UIFont) -> CGFloat {
        return self.size(withConstrainedHeight: height, constrainedWidth: .greatestFiniteMagnitude, font: font).width
    }

    func size(withConstrainedHeight height: CGFloat, constrainedWidth width: CGFloat, font: UIFont) -> CGSize {
        let attributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: font]
        let attributedString = NSAttributedString(string: self, attributes: attributes)
        let frameSetter = CTFramesetterCreateWithAttributedString(attributedString)
        return CTFramesetterSuggestFrameSizeWithConstraints(frameSetter, CFRange(location: 0, length: 0), nil, CGSize(width: width, height: .greatestFiniteMagnitude), nil)
    }
}
#endif
