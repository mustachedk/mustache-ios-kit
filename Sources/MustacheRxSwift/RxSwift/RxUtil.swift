import RxSwift
import RxCocoa
import Foundation

// workaround for Swift compiler bug, cheers compiler team :)
public func castOptionalOrFatalError<T>(_ value: Any?) -> T? {
    if value == nil {
        return nil
    }
    let v: T = castOrFatalError(value)
    return v
}

public func castOrThrow<T>(_ resultType: T.Type, _ object: Any) throws -> T {
    guard let returnValue = object as? T else {
        throw RxCocoaError.castingError(object: object, targetType: resultType)
    }

    return returnValue
}

public func castOptionalOrThrow<T>(_ resultType: T.Type, _ object: AnyObject) throws -> T? {
    if NSNull().isEqual(object) {
        return nil
    }

    guard let returnValue = object as? T else {
        throw RxCocoaError.castingError(object: object, targetType: resultType)
    }

    return returnValue
}

public func castOrFatalError<T>(_ value: AnyObject!, message: String) -> T {
    let maybeResult: T? = value as? T
    guard let result = maybeResult else {
        fatalError(message)
    }
    
    return result
}

public func castOrFatalError<T>(_ value: Any!) -> T {
    let maybeResult: T? = value as? T
    guard let result = maybeResult else {
        fatalError("Failure converting from \(String(describing: value)) to \(T.self)")
    }
    
    return result
}

infix operator <->

public func <-><T: Equatable>(BehaviorRelay: BehaviorRelay<T>, property: ControlProperty<T>) -> Disposable {
    let BehaviorRelayToProperty = BehaviorRelay.asObservable()
            .distinctUntilChanged()
            .bind(to: property)

    let propertyToBehaviorRelay = property
            .distinctUntilChanged()
            .bind(to: BehaviorRelay)

    return Disposables.create(BehaviorRelayToProperty, propertyToBehaviorRelay)
}

public func <-><T: Equatable>(property: ControlProperty<T>, BehaviorRelay: BehaviorRelay<T>) -> Disposable {
    let BehaviorRelayToProperty = BehaviorRelay.asObservable()
            .distinctUntilChanged()
            .bind(to: property)

    let propertyToBehaviorRelay = property
            .distinctUntilChanged()
            .bind(to: BehaviorRelay)

    return Disposables.create(BehaviorRelayToProperty, propertyToBehaviorRelay)
}

public func <-><T: Equatable>(left: BehaviorRelay<T>, right: BehaviorRelay<T>) -> Disposable {
    let leftToRight = left.asObservable()
            .distinctUntilChanged()
            .bind(to: right)

    let rightToLeft = right
            .distinctUntilChanged()
            .bind(to: left)

    return Disposables.create(leftToRight, rightToLeft)
}

public func <-><T: Equatable>(left: PublishSubject<T>, right: ControlProperty<T>) -> Disposable {
    let leftToRight = left.asObservable()
            .distinctUntilChanged()
            .bind(to: right)

    let rightToLeft = right.asObservable()
            .distinctUntilChanged()
            .bind(to: left)

    return Disposables.create(leftToRight, rightToLeft)
}

public func <-><T: Equatable>(left: ControlProperty<T>, right: PublishSubject<T>) -> Disposable {
    let leftToRight = left.asObservable()
            .distinctUntilChanged()
            .bind(to: right)

    let rightToLeft = right.asObservable()
            .distinctUntilChanged()
            .bind(to: left)

    return Disposables.create(leftToRight, rightToLeft)
}

public enum MustacheRxSwiftError: Error {
    case deallocated
}
