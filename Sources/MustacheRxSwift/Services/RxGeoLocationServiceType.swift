import Foundation
import UIKit
import CoreLocation
import MustacheServices

import RxSwift
import RxSwiftExt


public protocol RxGeoLocationServiceType {

    var authorized: RxObservable<Bool>! { get }

    var status: RxObservable<CLAuthorizationStatus>! { get }

    var location: RxObservable<CLLocation> { get }

}

@available(iOS 14.0, *)
public class RxGeoLocationService: RxGeoLocationServiceType {

    public var authorized: RxObservable<Bool>!

    public var status: RxObservable<CLAuthorizationStatus>!

    public lazy var location: RxObservable<CLLocation> = {
        return locationManager.rx.didUpdateLocations
                .filter({ (locations: [CLLocation]) -> Bool in
                    return locations.count > 0
                })
                .map({ (locations: [CLLocation]) -> CLLocation in
                    return locations.first!
                })
                .share(replay: 1)
                .do(onSubscribe: { [weak self] in
                    guard let self = self else { return }
                    self.locationManager.startUpdatingLocation()
                }, onDispose: { [weak self] in
                    guard let self = self else { return }
                    self.locationManager.stopUpdatingLocation()
                })
    }()

    fileprivate let disposeBag = DisposeBag()

    fileprivate let locationManager = CLLocationManager()

    public init() {

        self.locationManager.distanceFilter = kCLDistanceFilterNone
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation

        self.authorized = self.locationManager.rx.didChangeAuthorizationStatus.startWith(self.locationManager.authorizationStatus).map( { [weak self] (status: CLAuthorizationStatus) -> Bool in
            switch status {
                case .authorizedWhenInUse, .authorizedAlways:
                    guard let self = self else { return true }
                    self.locationManager.startUpdatingLocation()
                    return true
                default:
                    return false
            }
        })

        self.status = self.locationManager.rx.didChangeAuthorizationStatus.startWith(self.locationManager.authorizationStatus)

    }
}
