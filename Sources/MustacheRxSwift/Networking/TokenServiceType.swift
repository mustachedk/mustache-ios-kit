
import Foundation
import MustacheServices
import RxSwift

public protocol TokenServiceType {

    func updateToken() -> Observable<Void>

}
