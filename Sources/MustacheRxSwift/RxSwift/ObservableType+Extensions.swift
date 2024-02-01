
import Foundation

import RxSwift

let 🤷: Void = Void()

public typealias RxObservable = RxSwift.Observable

public extension ObservableType {

    func mapFilter<Input>(_ isIncluded: @escaping (Input) throws -> Bool) -> RxObservable<Array<Input>> where Element: Collection, Element.Element == Input {
        return map { try $0.filter(isIncluded) }
    }

    func mapVoid() -> RxObservable<Void> {
        return self.map { _ in return 🤷 }
    }

}

public extension ObservableType {

    func withPrevious(startWith first: Element) -> RxObservable<(Element, Element)> {
        return self.withPrevious(startWith: first, skip: 0)
    }

    func withPrevious(startWith first: Element, skip: Int) -> RxObservable<(Element, Element)> {
        return scan((first, first)) { ($0.1, $1) }.skip(skip)
    }
}

extension RxObservable where Element: DefaultInit {
    static var just: RxObservable<DefaultInit> { RxObservable<DefaultInit>.just(Element.init()) }
}

extension RxObservable where Element == Void {
    static var just: RxObservable<Void> { RxObservable<Void>.just(()) }
}

extension Single where Element: DefaultInit {
    static var just: RxObservable<DefaultInit> { RxObservable<DefaultInit>.just(Element.init()) }
}

extension Single where Element == Void {
    static var just: RxObservable<Void> { RxObservable<Void>.just(()) }
}

protocol DefaultInit {
    init()
}

extension String: DefaultInit {}

extension Date: DefaultInit {}

extension Int: DefaultInit {}

extension Bool: DefaultInit {}


