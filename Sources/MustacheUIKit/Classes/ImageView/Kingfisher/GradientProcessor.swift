
#if canImport(UIKit)
import Foundation
import UIKit

#if canImport(Kingfisher)
import Kingfisher

/// A ImageProcessor that applies a gradient color to and image
public struct GradientProcessor: ImageProcessor {
    
    var locations: [CGFloat] = [0.0, 0.15, 0.85, 1.0]
    var colors: [CGColor] = [UIColor.lightGray.cgColor, UIColor.clear.cgColor, UIColor.clear.cgColor, UIColor.lightGray.cgColor]
    
    public let identifier = "dk.mustache.gradientprocessor"
    
    public init() {}
    
    init(locations: [Double], colors: [UIColor]) {
        self.locations = locations.map { $0.cgfloat }
        self.colors = colors.map { $0.cgColor }
    }
    
    // Convert input data/image to target image and return it.
    public func process(item: ImageProcessItem, options: KingfisherParsedOptionsInfo) -> KFCrossPlatformImage? {
        switch item {
            case .image(let image):
                return image.withGradient(locations: locations, colors: colors)
            case .data(let data):
                guard let image = UIImage(data: data) else { return nil }
                return image.withGradient(locations: locations, colors: colors)
        }
    }
}

#endif

public extension UIImage {
    
    func withGradient(locations: [CGFloat], colors: [CGColor]) -> UIImage {
        
        UIGraphicsBeginImageContext(self.size)
        
        let context = UIGraphicsGetCurrentContext()
        
        self.draw(at: CGPoint(x: 0, y: 0))
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let locations: [CGFloat] = locations
        
        let colors = colors as CFArray
        
        let gradient = CGGradient(colorsSpace: colorSpace, colors: colors, locations: locations)
        
        let startPoint = CGPoint(x: self.size.width / 2, y: 0)
        let endPoint = CGPoint(x: self.size.width / 2, y: self.size.height)
        
        context!.drawLinearGradient(gradient!, start: startPoint, end: endPoint, options: CGGradientDrawingOptions(rawValue: UInt32(0)))
        
        guard let image = UIGraphicsGetImageFromCurrentImageContext() else { return self }
        
        UIGraphicsEndImageContext()
        
        return image
    }
}
#endif
