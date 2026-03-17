
import Foundation
import Factory

import MustacheServices

import RxSwift

// MARK: - MustacheRxSwift Container Definitions

public extension Container {

    // MARK: RxSwift Networking

    var tokenService: Factory<(any TokenServiceType)?> {
        self { nil }
    }

    var renewTokenService: Factory<(any RenewTokenServiceType)?> {
        self { nil }
    }

}
