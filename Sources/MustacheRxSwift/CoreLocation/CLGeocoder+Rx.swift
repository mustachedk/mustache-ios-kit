
#if canImport(CoreLocation)
import CoreLocation
import Contacts

import RxSwift

public extension CLLocation {
    convenience init(coordinate: CLLocationCoordinate2D) {
        self.init(latitude: coordinate.latitude, longitude: coordinate.longitude)
    }
}

public extension Reactive where Base: CLGeocoder {

    func reverseGeocodeLocation(location: CLLocation) -> RxObservable<[CLPlacemark]> {
        return RxObservable<[CLPlacemark]>.create { observer in
            geocodeHandler(observer: observer, geocode: curry2(self.base.reverseGeocodeLocation, location))
            return Disposables.create { self.base.cancelGeocode() }
        }
    }

    func reverseGeocodeLocation(coordinate: CLLocationCoordinate2D) -> RxObservable<[CLPlacemark]> {
        return RxObservable<[CLPlacemark]>.create { observer in
            let location = CLLocation(coordinate: coordinate)
            geocodeHandler(observer: observer, geocode: curry2(self.base.reverseGeocodeLocation, location))
            return Disposables.create { self.base.cancelGeocode() }
        }
    }

    @available(iOS 11.0, *)
    func geocodePostalAddress(_ postalAddress: CNPostalAddress) -> RxObservable<[CLPlacemark]> {
        return RxObservable<[CLPlacemark]>.create { observer in
            geocodeHandler(observer: observer, geocode: curry2(self.base.geocodePostalAddress, postalAddress))
            return Disposables.create { self.base.cancelGeocode() }
        }
    }

    func geocodeAddressString(addressString: String) -> RxObservable<[CLPlacemark]> {
        return RxObservable<[CLPlacemark]>.create { observer in
            geocodeHandler(observer: observer, geocode: curry2(self.base.geocodeAddressString, addressString))
            return Disposables.create { self.base.cancelGeocode() }
        }
    }

    func geocodeAddressString(addressString: String, inRegion region: CLRegion?) -> RxObservable<[CLPlacemark]> {
        return RxObservable<[CLPlacemark]>.create { observer in
            geocodeHandler(observer: observer, geocode: curry3(self.base.geocodeAddressString, addressString, region))
            return Disposables.create { self.base.cancelGeocode() }
        }
    }
}

private func curry2<A, B, C>(_ f: @escaping (A, B) -> C, _ a: A) -> (B) -> C {
    return { b in f(a, b) }
}

private func curry3<A, B, C, D>(_ f: @escaping (A, B, C) -> D, _ a: A, _ b: B) -> (C) -> D {
    return { c in f(a, b, c) }
}

private func geocodeHandler(observer: AnyObserver<[CLPlacemark]>, geocode: @escaping (@escaping CLGeocodeCompletionHandler) -> Void) {
    let semaphore = DispatchSemaphore(value: 0)
    waitForCompletionQueue.async {
        geocode { placemarks, error in
            semaphore.signal()
            if let placemarks = placemarks {
                observer.onNext(placemarks)
                observer.onCompleted()
            } else if let error = error {
                observer.onError(error)
            } else {
                observer.onError(RxError.unknown)
            }
        }
        _ = semaphore.wait(timeout: .now() + 30)
    }
}

private let waitForCompletionQueue = DispatchQueue(label: "WaitForGeocodeCompletionQueue")

#endif
