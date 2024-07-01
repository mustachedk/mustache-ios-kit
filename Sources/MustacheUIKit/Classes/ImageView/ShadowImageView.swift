
#if canImport(UIKit)

import Foundation
import UIKit

public class ShadowImageView: UIImageView {

    fileprivate var originalImage: UIImage?

    override open var image: UIImage? {
        didSet {
            self.originalImage = self.image
            self.invalidateIntrinsicContentSize()
            self.configureShadow()
        }
    }
    open override var tintColor: UIColor! {
        didSet { self.configureShadow() }
    }

    @IBInspectable
    open var sketchColor: UIColor = .black

    @IBInspectable
    open var sketchAlpha: CGFloat = 0.5

    @IBInspectable
    open var sketchX: CGFloat = 0

    @IBInspectable
    open var sketchY: CGFloat = 0

    @IBInspectable
    open var sketchBlur: CGFloat = 0

    override open var intrinsicContentSize: CGSize {
        return self.originalImage?.size ?? self.image?.size ?? .zero
    }

    override init(image: UIImage?) {
        super.init(image: image)
        self.configure()
    }

    override init(image: UIImage?, highlightedImage: UIImage?) {
        super.init(image: image, highlightedImage: highlightedImage)
        self.configure()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.configure()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.configure()
    }

    fileprivate func configure() {
        self.contentMode = .topLeft
        self.clipsToBounds = false

        let image = self.image
        self.image = image
    }

    fileprivate func configureShadow() {
        defer { UIGraphicsEndImageContext() }
        guard var image = self.originalImage else { return }
        let size = CGSize(width: image.size.width + self.sketchX + (self.sketchBlur / 2), height: image.size.height + self.sketchY + (self.sketchBlur / 2))
        UIGraphicsBeginImageContextWithOptions(size, false, UIScreen.main.scale)
        guard let context = UIGraphicsGetCurrentContext() else { return }

        if image.renderingMode == .alwaysTemplate { image = image.tint(tintColor: self.tintColor) }

        context.setShadow(offset: CGSize(width: self.sketchX, height: sketchY), blur: self.sketchBlur, color: self.sketchColor.withAlphaComponent(self.sketchAlpha).cgColor)
        image.draw(at: .zero)
        let imageWithShadow = UIGraphicsGetImageFromCurrentImageContext()
        super.image = imageWithShadow ?? image
    }

    override open func awakeFromNib() {
        super.awakeFromNib()
        self.configureShadow()
    }

}

#endif
