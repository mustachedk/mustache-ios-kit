
import Foundation
import Factory

// MARK: - Re-export Factory for consuming apps

@_exported import Factory

// MARK: - MustacheServices Container Definitions

public extension Container {

    // MARK: Async Networking

    @available(iOS 13.0, macOS 15, *)
    var asyncCredentialsService: Factory<any AsyncCredentialsServiceType> {
        self { AsyncCredentialsService() }.singleton
    }

    @available(iOS 13.0, macOS 15, *)
    var asyncTokenService: Factory<any AsyncTokenServiceType> {
        self { AsyncTokenService() }.singleton
    }

    @available(iOS 13.0, macOS 15, *)
    var asyncNetworkService: Factory<any AsyncNetworkServiceType> {
        self { AsyncNetworkService() }.shared
    }

    var refreshTokenService: Factory<(any RefreshTokenServiceType)?> {
        self { nil }
    }

    // MARK: Sync Networking

    var credentialsService: Factory<(any CredentialsServiceType)?> {
        self { nil }
    }

    var networkService: Factory<(any NetworkServiceType)?> {
        self { nil }
    }

    // MARK: Services

    var connectivityService: Factory<(any ConnectivityServiceType)?> {
        self { nil }
    }

    var secureStorageMaxPinAttempts: Factory<Int> {
        self { 10 }
    }

}
