import MapKit
import RxSwift

public extension MKLocalSearch {

    func mapItems() -> Observable<[MKMapItem]> {
        return Observable.create { observer in
            self.start(completionHandler: { (response, error) in
                if let error = error {
                    observer.onError(error)
                } else {
                    let items = response?.mapItems ?? []
                    observer.onNext(items)
                    observer.onCompleted()
                }
            })
            return Disposables.create {
                self.cancel()
            }
        }
    }
}
