
import Foundation
import MapKit

public extension MKAnnotationView {
    #if canImport(UIKit)
    var identifier: String { return String(describing: self) }
    #endif
}
