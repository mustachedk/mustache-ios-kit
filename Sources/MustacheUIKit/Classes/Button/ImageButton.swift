#if canImport(UIKit)
import Foundation
import UIKit

open class ImageButton: Button {

    /**
    Convenience init for button with image and minimum hit size of 44x44

    - parameters:
        - image: UIImage

    - returns:
        ImageButton

    */
    public convenience init(image: UIImage) {
        self.init(frame: .zero)
        self.setImage(image, for: UIControl.State())
    }

    override public init(frame: CGRect) { super.init(frame: frame) }

    public required init?(coder: NSCoder) { super.init(coder: coder) }

    open override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        // Ignore if button hidden
        guard !self.isHidden else { return nil }

        // If here, button visible so expand hit area
        let hitSize = CGFloat(44.0)
        let buttonSize = self.frame.size
        let widthToAdd = (hitSize - buttonSize.width > 0) ? hitSize - buttonSize.width : 0
        let heightToAdd = (hitSize - buttonSize.height > 0) ? hitSize - buttonSize.height : 0
        let largerFrame = CGRect(x: 0 - (widthToAdd / 2), y: 0 - (heightToAdd / 2), width: buttonSize.width + widthToAdd, height: buttonSize.height + heightToAdd)
        return largerFrame.contains(point) ? self : nil

    }

}
#endif
