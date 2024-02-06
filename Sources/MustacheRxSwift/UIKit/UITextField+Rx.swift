//
//  UITextField+Rx.swift
//
//  Created by Lex Tang on 2/14/18.
//  Copyright © 2018 Krunoslav Zaher. All rights reserved.
//

#if canImport(UIKit)

import UIKit

#if canImport(RxCocoa)

import RxSwift
import RxCocoa

public extension UITextField {

    /// Factory method that enables subclasses to implement their own `delegate`.
    ///
    /// - returns: Instance of delegate proxy that wraps `delegate`.
    func createRxDelegateProxy() -> RxTextFieldDelegateProxy {
        return RxTextFieldDelegateProxy(textField: self)
    }

}

public extension Reactive where Base: UITextField {

    /// Reactive wrapper for `delegate`.
    ///
    /// For more information take a look at `DelegateProxyType` protocol documentation.
    var delegate: DelegateProxy<UITextField, UITextFieldDelegate> {
        return RxTextFieldDelegateProxy.proxy(for: base)
    }

    /// Reactive wrapper for `delegate` message.
    var shouldReturn: ControlEvent<Void> {
        let source = delegate.rx.methodInvoked(#selector(UITextFieldDelegate.textFieldShouldReturn))
            .map { _ in }

        return ControlEvent(events: source)
    }

    var shouldClear: ControlEvent<Void> {
        let source = delegate.rx.methodInvoked(#selector(UITextFieldDelegate.textFieldShouldClear))
            .map { _ in }

        return ControlEvent(events: source)
    }

}

//
//  RxTextFieldDelegateProxy.swift
//
//  Created by Lex Tang on 2/14/18.
//  Copyright © 2018 Krunoslav Zaher. All rights reserved.
//


open class RxTextFieldDelegateProxy: DelegateProxy<UITextField, UITextFieldDelegate>, DelegateProxyType, UITextFieldDelegate {
    
    public static func currentDelegate(for object: UITextField) -> UITextFieldDelegate? {
        return object.delegate
    }
    
    public static func setCurrentDelegate(_ delegate: UITextFieldDelegate?, to object: UITextField) {
        object.delegate = delegate
    }
    
    /// Typed parent object.
    public weak private(set) var textField: UITextField?
    
    /// - parameter textfield: Parent object for delegate proxy.
    public init(textField: ParentObject) {
        self.textField = textField
        super.init(parentObject: textField, delegateProxy: RxTextFieldDelegateProxy.self)
    }
    
    // Register known implementations
    public static func registerKnownImplementations() {
        register(make: RxTextFieldDelegateProxy.init)
    }
    
    // MARK: delegate methods
    /// For more information take a look at `DelegateProxyType`.
    @objc open func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return forwardToDelegate()?.textFieldShouldReturn?(textField) ?? true
    }
    
    @objc open func textFieldShouldClear(_ textField: UITextField) -> Bool {
        return forwardToDelegate()?.textFieldShouldClear?(textField) ?? true
    }
}

#endif

#endif

