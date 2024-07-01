#if canImport(UIKit)

import UIKit

// fixing Bug in XCode
// http://openradar.appspot.com/18448072
extension UIImageView {

    convenience init(string: String, font: UIFont, color: UIColor) {
        self.init(image: UILabel(string: string, font: font, color: color).snapshot())
    }

    override open func awakeFromNib() {
        super.awakeFromNib()
        self.tintColorDidChange()
    }

    func addShadowToImageNotLayer(blurSize: CGFloat = 8.0) {

      let shadowColor = UIColor(white: 0.0, alpha: 0.55).cgColor

      guard let image = self.image else {return}

      let context = CGContext(data: nil,
                              width: Int(image.size.width + blurSize),
                              height: Int(image.size.height + blurSize),
                              bitsPerComponent: image.cgImage!.bitsPerComponent,
                              bytesPerRow: 0,
                              space: CGColorSpaceCreateDeviceRGB(),
                              bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!

      context.setShadow(offset: CGSize(width: blurSize / 2, height: -blurSize / 2),
                        blur: blurSize,
                        color: shadowColor)

      context.draw(image.cgImage!,
                   in: CGRect(x: 0, y: blurSize, width: image.size.width, height: image.size.height),
                   byTiling: false)

      self.image = UIImage(cgImage: context.makeImage()!)

    }
    
}
#endif
