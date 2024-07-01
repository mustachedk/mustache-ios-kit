
#if canImport(UIKit)

import UIKit
import Combine

@available(iOS 13.0, macOS 15, *)
extension UIControl {
    
    class EventControlSubscription<EventSubscriber: Subscriber, Control: UIControl>: Subscription where EventSubscriber.Input == Control, EventSubscriber.Failure == Never {
        
        let control: Control
        let event: UIControl.Event
        var subscriber: EventSubscriber?
        
        var currentDemand: Subscribers.Demand = .none
        
        init(control: Control, event: UIControl.Event, subscriber: EventSubscriber) {
            self.control = control
            self.event = event
            self.subscriber = subscriber
            
            control.addTarget(self, action: #selector(eventRaised), for: event)
        }
        
        func request(_ demand: Subscribers.Demand) {
            currentDemand += demand
        }
        
        func cancel() {
            subscriber = nil
            control.removeTarget(self, action: #selector(eventRaised), for: event)
        }
        
        @objc func eventRaised() {
            if currentDemand > 0 {
                currentDemand += subscriber?.receive(control) ?? .none
                currentDemand -= 1
            }
        }
    }
}
#endif


