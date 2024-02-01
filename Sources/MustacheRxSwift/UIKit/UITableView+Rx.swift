
import Foundation
import RxSwift

import UIKit

public extension Reactive where Base: UITableView {

    /// Bindable sink for `reload` property.
    var reloadData: Binder<Void> {
        return Binder(self.base) { tableView, _ in
            tableView.reloadData()
        }
    }
}
