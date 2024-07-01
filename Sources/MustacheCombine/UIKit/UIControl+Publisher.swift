
#if canImport(UIKit)

import Combine
import UIKit

@available(iOS 13.0, macOS 15, *)
extension UIControl {
 
    
    public struct EventControlPublisher<Control: UIControl>: Publisher {
        public typealias Output = Control
        public typealias Failure = Never
        
        let control: Control
        let controlEvent: UIControl.Event
        
        public func receive<S>(subscriber: S) where S : Subscriber, Failure == S.Failure, Output == S.Input {
            let subscription = EventControlSubscription(control: control, event: controlEvent, subscriber: subscriber)
            subscriber.receive(subscription: subscription)
        }
    }
}

public protocol Combinable {}

extension UIControl: Combinable {}

@available(iOS 13.0, macOS 15, *)
public extension Combinable where Self: UIControl {
    
    func publisher(for event: UIControl.Event) -> UIControl.EventControlPublisher<Self> {
        return UIControl.EventControlPublisher(control: self, controlEvent: event)
    }
    
}
#endif

