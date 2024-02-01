import UIKit
import RxSwift
import RxSwiftExt


public extension Reactive where Base: UIPickerView {

    func selected<T>(_ modelType: T.Type) -> RxObservable<T> {
        return self.modelSelected(T.self)
                .map { models -> T? in return models.first }
                .unwrap()
    }

    func selectedModel<T>() throws -> T {
        let selectedRow = self.base.selectedRow(inComponent: 0)
        let index = IndexPath(row: selectedRow, section: 0)
        return try self.model(at: index)
    }

}
