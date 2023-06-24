import RxSwift
import Foundation

public extension URLSession {

    func dataTask(with request: URLRequest) -> Observable<(Data?, URLResponse?)> {
        return Observable.create { (observer: AnyObserver<(Data?, URLResponse?)>) in
            let task = self.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) -> Void in
                if let error = error {
                    observer.onError(error)
                }
                observer.onNext((data, response))
                observer.onCompleted()
            }
            task.resume()
            return Disposables.create {
                task.cancel()
            }
        }
    }
}
