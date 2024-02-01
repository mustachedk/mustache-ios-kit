import MapKit
import RxSwift
import RxCocoa

public extension Reactive where Base: MKMapView {

    /**
     Reactive wrapper for `delegate`.

     For more information take a look at `DelegateProxyType` protocol documentation.
     */
    var delegate: DelegateProxy<MKMapView, MKMapViewDelegate> {
        return RxMKMapViewDelegateProxy.proxy(for: base)
    }

    // MARK: Responding to Map Position Changes

    var regionWillChangeAnimated: ControlEvent<Bool> {
        let source = delegate
                .methodInvoked(#selector(MKMapViewDelegate.mapView(_:regionWillChangeAnimated:)))
                .map { a in
                    return try castOrThrow(Bool.self, a[1])
                }
        return ControlEvent(events: source)
    }

    var regionDidChangeAnimated: ControlEvent<MKMapRect> {
        let source = delegate.methodInvoked(#selector(MKMapViewDelegate.mapView(_:regionDidChangeAnimated:)))
                .map { a -> MKMapRect in
                    let mapView = try castOrThrow(MKMapView.self, a[0])
                    return mapView.visibleMapRect
                }
        return ControlEvent(events: source)
    }

    // MARK: Loading the Map Data

    var willStartLoadingMap: ControlEvent<Void> {
        let source = delegate
                .methodInvoked(#selector(MKMapViewDelegate.mapViewWillStartLoadingMap(_:)))
                .map { _ in
                    return ()
                }
        return ControlEvent(events: source)
    }

    var didFinishLoadingMap: ControlEvent<Void> {
        let source = delegate
                .methodInvoked(#selector(MKMapViewDelegate.mapViewDidFinishLoadingMap(_:)))
                .map { _ in
                    return ()
                }
        return ControlEvent(events: source)
    }

    var didFailLoadingMap: RxObservable<NSError> {
        return delegate
                .methodInvoked(#selector(MKMapViewDelegate.mapViewDidFailLoadingMap(_:withError:)))
                .map { a in
                    return try castOrThrow(NSError.self, a[1])
                }
    }

    // MARK: Responding to Rendering Events

    var willStartRenderingMap: ControlEvent<Void> {
        let source = delegate
                .methodInvoked(#selector(MKMapViewDelegate.mapViewWillStartRenderingMap(_:)))
                .map { _ in
                    return ()
                }
        return ControlEvent(events: source)
    }

    var didFinishRenderingMap: ControlEvent<Bool> {
        let source = delegate
                .methodInvoked(#selector(MKMapViewDelegate.mapViewDidFinishRenderingMap(_:fullyRendered:)))
                .map { a in
                    return try castOrThrow(Bool.self, a[1])
                }
        return ControlEvent(events: source)
    }

    // MARK: Tracking the User Location

    var willStartLocatingUser: ControlEvent<Void> {
        let source = delegate
                .methodInvoked(#selector(MKMapViewDelegate.mapViewWillStartLocatingUser(_:)))
                .map { _ in
                    return ()
                }
        return ControlEvent(events: source)
    }

    var didStopLocatingUser: ControlEvent<Void> {
        let source = delegate
                .methodInvoked(#selector(MKMapViewDelegate.mapViewDidStopLocatingUser(_:)))
                .map { _ in
                    return ()
                }
        return ControlEvent(events: source)
    }

    var didUpdateUserLocation: ControlEvent<MKUserLocation> {
        let source = delegate
                .methodInvoked(#selector(MKMapViewDelegate.mapView(_:didUpdate:)))
                .map { a in
                    return try castOrThrow(MKUserLocation.self, a[1])
                }
        return ControlEvent(events: source)
    }

    var didFailToLocateUserWithError: RxObservable<NSError> {
        return delegate
                .methodInvoked(#selector(MKMapViewDelegate.mapView(_:didFailToLocateUserWithError:)))
                .map { a in
                    return try castOrThrow(NSError.self, a[1])
                }
    }

    var didChangeUserTrackingMode: ControlEvent<(mode: MKUserTrackingMode, animated: Bool)> {
        let source = delegate
                .methodInvoked(#selector(MKMapViewDelegate.mapView(_:didChange:animated:)))
                .map { a in
                    return (mode: try castOrThrow(Int.self, a[1]),
                            animated: try castOrThrow(Bool.self, a[2]))
                }
                .map { (mode, animated) in
                    return (mode: MKUserTrackingMode(rawValue: mode)!,
                            animated: animated)
                }
        return ControlEvent(events: source)
    }

    // MARK: Responding to Annotation Views

//    var didAddAnnotationViews: ControlEvent<[MKAnnotationView]> {
//        
//        let selector = #selector((MKMapViewDelegate.mapView(_:didAdd:))! as (MKMapViewDelegate) -> (MKMapView, [MKAnnotationView]) -> Void)
//        
//        let source = delegate
//                .methodInvoked(selector)
//                .map { a in
//                    return try castOrThrow([MKAnnotationView].self, a[1])
//                }
//        return ControlEvent(events: source)
//    }

    var annotationViewCalloutAccessoryControlTapped: ControlEvent<(view: MKAnnotationView, control: UIControl)> {
        let source = delegate
                .methodInvoked(#selector(MKMapViewDelegate.mapView(_:annotationView:calloutAccessoryControlTapped:)))
                .map { a in
                    return (view: try castOrThrow(MKAnnotationView.self, a[1]),
                            control: try castOrThrow(UIControl.self, a[2]))
                }
        return ControlEvent(events: source)
    }

    // MARK: Selecting Annotation Views

    var didSelectAnnotationView: ControlEvent<MKAnnotationView> {
        let source = delegate
                .methodInvoked(#selector(MKMapViewDelegate.mapView(_:didSelect:)))
                .map { a in
                    return try castOrThrow(MKAnnotationView.self, a[1])
                }
        return ControlEvent(events: source)
    }

    var didDeselectAnnotationView: ControlEvent<MKAnnotationView> {
        let source = delegate
                .methodInvoked(#selector(MKMapViewDelegate.mapView(_:didDeselect:)))
                .map { a in
                    return try castOrThrow(MKAnnotationView.self, a[1])
                }
        return ControlEvent(events: source)
    }

    var didChangeState: ControlEvent<(view: MKAnnotationView, newState: MKAnnotationView.DragState, oldState: MKAnnotationView.DragState)> {
        let source = delegate
                .methodInvoked(#selector(MKMapViewDelegate.mapView(_:annotationView:didChange:fromOldState:)))
                .map { a in
                    return (view: try castOrThrow(MKAnnotationView.self, a[1]),
                            newState: try castOrThrow(UInt.self, a[2]),
                            oldState: try castOrThrow(UInt.self, a[3]))
                }
                .map { (view, newState, oldState) in
                    return (view: view,
                            newState: MKAnnotationView.DragState(rawValue: newState)!,
                            oldState: MKAnnotationView.DragState(rawValue: oldState)!)
                }
        return ControlEvent(events: source)
    }

    // MARK: Managing the Display of Overlays

//    var didAddOverlayRenderers: ControlEvent<[MKOverlayRenderer]> {
//        let source = delegate
//                .methodInvoked(#selector(
//                               (MKMapViewDelegate.mapView(_:didAdd:))!
//                                       as (MKMapViewDelegate) -> (MKMapView, [MKOverlayRenderer]) -> Void
//                               )
//                )
//                .map { a in
//                    return try castOrThrow([MKOverlayRenderer].self, a[1])
//                }
//        return ControlEvent(events: source)
//    }

    // MARK: Binding annotation to the Map

    func annotations<S: Sequence, O: ObservableType>(_ source: O)
                    -> (_ transform: @escaping (S.Iterator.Element) -> MKAnnotation)
            -> Disposable where O.Element == S {

        return { factory in
            source.map { elements -> [MKAnnotation] in
                        elements.map(factory)
                    }
                    .bind(to: self.annotations)
        }
    }

    func annotations<O: ObservableType>(_ source: O)
                    -> Disposable where O.Element == [MKAnnotation] {
        return source.subscribe(AnyObserver { event in
            if case let .next(element) = event {

                let newHashValues = Set(element.map { $0.hash })
                let existingHashValues = Set(self.base.annotations.map { $0.hash })

                let removedHashes = existingHashValues.subtracting(newHashValues)
                let addedHashed = newHashValues.subtracting(existingHashValues)

                let removed = self.base.annotations.filter({ removedHashes.contains($0.hash) })
                let added = element.filter({ addedHashed.contains($0.hash) })

                self.base.removeAnnotations(removed)
                self.base.addAnnotations(added)
            }
        })
    }

    func annotations<O: ObservableType>(_ source: O)
                    -> Disposable where O.Element: MKAnnotation {
        return source.subscribe(AnyObserver { event in
            if case let .next(element) = event {
                if !self.base.annotations.map({ $0.hash }).contains(element.hash) { self.base.addAnnotation(element) }
            }
        })
    }
}


fileprivate func castOrThrow<T>(_ resultType: T.Type, _ object: Any) throws -> T {
    guard let returnValue = object as? T else {
        throw RxCocoaError.castingError(object: object, targetType: resultType)
    }

    return returnValue
}

fileprivate func castOptionalOrThrow<T>(_ resultType: T.Type, _ object: Any) throws -> T? {
    if NSNull().isEqual(object) {
        return nil
    }

    guard let returnValue = object as? T else {
        throw RxCocoaError.castingError(object: object, targetType: resultType)
    }

    return returnValue
}
