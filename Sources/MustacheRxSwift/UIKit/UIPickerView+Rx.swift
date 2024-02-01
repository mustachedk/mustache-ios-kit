
import UIKit

#if canImport(RxCocoa)

import RxSwift
import RxCocoa

public extension Reactive where Base: UIPickerView {

    func selected<T>(_ modelType: T.Type) -> RxObservable<T> {
        return self.modelSelected(T.self)
                .map { models -> T? in return models.first }
                .compactMap { $0 }
    }

    func selectedModel<T>() throws -> T {
        let selectedRow = self.base.selectedRow(inComponent: 0)
        let index = IndexPath(row: selectedRow, section: 0)
        return try self.model(at: index)
    }

}

#endif
