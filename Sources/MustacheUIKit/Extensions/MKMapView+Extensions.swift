
import Foundation
import MapKit

public extension MKMapView {

    var widthOfMapViewInMeters: Double {
        let eastMapPoint = MKMapPoint(x: self.visibleMapRect.minX, y: self.visibleMapRect.midY)
        let westMapPoint = MKMapPoint(x: self.visibleMapRect.maxX, y: self.visibleMapRect.midY)
        let currentDistWideInMeters = eastMapPoint.distance(to: westMapPoint)
        return currentDistWideInMeters
    }

    var heightOfMapViewInMeters: Double {
        let northMapPoint = MKMapPoint(x: self.visibleMapRect.midX, y: self.visibleMapRect.minY)
        let southMapPoint = MKMapPoint(x: self.visibleMapRect.midX, y: self.visibleMapRect.maxY)
        let currentDistHeightInMeters = northMapPoint.distance(to: southMapPoint)
        return currentDistHeightInMeters
    }

    func setRegion(coordinate: CLLocationCoordinate2D, distance: Double, animated: Bool) {
        let maximumSide = max(self.frame.height, self.frame.width)
        let minimumSide = min(self.frame.height, self.frame.width)

        var formFactor = minimumSide / maximumSide
        if formFactor.isNaN {
            formFactor = 1
        }
        #if canImport(UIKit)
        let maxDistance = distance * formFactor.double
        #else
        let maxDistance = distance * Double(formFactor)
        #endif

        let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: maxDistance, longitudinalMeters: maxDistance)
        self.setRegion(region, animated: animated)
    }

    func closestAnnotationToUser() -> MKAnnotation? {
        let userLoc = CLLocation(latitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude)
        return annotations.closest(to: userLoc)
    }

}

public extension Array where Iterator.Element == MKAnnotation {

    func closest(to fixedLocation: CLLocation) -> Iterator.Element? {
        guard !self.isEmpty else { return nil}

        // create variables you'll use to track the smallest distance measured and the
        // closest annotation
        var closestAnnotation: Iterator.Element? = nil
        var smallestDistance: CLLocationDistance = Double.greatestFiniteMagnitude

        // loop through your mapview's annotations (if you're using a different type of annotation,
        // just substitude it here)
        for annotation in self {
            // create a location object from the coordinates for the annotation so you can easily
            // compare the two locations
            let locationForAnnotation = CLLocation(latitude: annotation.coordinate.latitude, longitude: annotation.coordinate.longitude)

            // calculate the distance between the user's location and the location you just created
            // from the annoatation's coordinates
            let distanceFromUser = fixedLocation.distance(from: locationForAnnotation)

            // if this calculated distance is smaller than the currently smallest distance, update the
            // smallest distance thus far as well as the closest annotation
            if distanceFromUser < smallestDistance {
                smallestDistance = distanceFromUser
                closestAnnotation = annotation
            }
        }

        // now you can do whatever you want with the closest annotation
        return closestAnnotation
    }
}
