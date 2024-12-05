
#if canImport(Kingfisher)

import Foundation
import Kingfisher
import UIKit

/// A ImageProcessor that cuts of the surrounding alpha of an UIImage
public struct CropAlphaProcessor: ImageProcessor {
    
    public let identifier = "dk.mustache.cropalphaprocessor"
    
    public init() {}
    
    // Convert input data/image to target image and return it.
    public func process(item: ImageProcessItem, options: KingfisherParsedOptionsInfo) -> KFCrossPlatformImage? {
        switch item {
            case .image(let image):
                return image.cropImageByAlpha()
            case .data(let data):
                guard let image = UIImage(data: data) else { return nil }
                return image.cropImageByAlpha()
        }
    }
}

/* Extension for croping transparent pixels
 example:
 let image: UIImage = UIImage(imageLiteral: "YOUR_IMAGE")
 let uiImageView = UIImageView(image: image.cropImageByAlpha())
 view.addSubview(uiImageView)
 
 Code was basically done here:
 http://stackoverflow.com/questions/9061800/how-do-i-autocrop-a-uiimage/13922413#13922413
 http://www.markj.net/iphone-uiimage-pixel-color/
 */
public extension UIImage {
    
    func cropImageByAlpha() -> UIImage {
        guard let cgImage = self.cgImage else { return self }
        guard let context = createARGBBitmapContextFromImage(inImage: cgImage) else { return self }
        let height = cgImage.height
        let width = cgImage.width
        var rect: CGRect = CGRect(x: 0, y: 0, width: CGFloat(width), height: CGFloat(height))
        context.draw(cgImage, in: rect)
        
        guard let data = context.data?.assumingMemoryBound(to: UInt8.self) else { return self }
        
        var minX = width
        var minY = height
        var maxX: Int = 0
        var maxY: Int = 0
        //Filter through data and look for non-transparent pixels.
        for y in 0..<height {
            for x in 0..<width {
                let pixelIndex = (width * y + x) * 4 /* 4 for A, R, G, B */
                if data[Int(pixelIndex)] != 0 { //Alpha value is not zero pixel is not transparent.
                    if (x < minX) {
                        minX = x
                    }
                    if (x > maxX) {
                        maxX = x
                    }
                    if (y < minY) {
                        minY = y
                    }
                    if (y > maxY) {
                        maxY = y
                    }
                }
            }
        }
        rect = CGRect(x: CGFloat(minX), y: CGFloat(minY), width: CGFloat(maxX - minX), height: CGFloat(maxY - minY))
        let imageScale: CGFloat = self.scale
        guard let cgiImage = cgImage.cropping(to: rect) else { return self }
        return UIImage(cgImage: cgiImage, scale: imageScale, orientation: self.imageOrientation)
    }
    
    private func createARGBBitmapContextFromImage(inImage: CGImage) -> CGContext? {
        let width = inImage.width
        let height = inImage.height
        let bitmapBytesPerRow = width * 4
        let bitmapByteCount = bitmapBytesPerRow * height
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapData = malloc(bitmapByteCount)
        if bitmapData == nil {
            return nil
        }
        let context = CGContext(data: bitmapData, width: width, height: height, bitsPerComponent: 8, bytesPerRow: bitmapBytesPerRow, space: colorSpace, bitmapInfo: CGImageAlphaInfo.premultipliedFirst.rawValue)
        return context
    }
}

#endif
