#if canImport(UIKit)

import UIKit

public extension UITableView {

    /**
    Add corners to the top and bottom cell in a UITableView, should be called from:
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath)

    - parameters:
        - cell: UITableViewCell
        - indexPath: IndexPath
        - radius: CGFloat
    */

    func addCorners(cell: UITableViewCell, indexPath: IndexPath, radius: CGFloat = 12) {

        let rows: Int = self.numberOfRows(inSection: indexPath.section) - 1
        let layer = CAShapeLayer()
        var addSeparator = false
        if indexPath.row == 0 && indexPath.row == rows {
            layer.path = UIBezierPath(roundedRect: cell.bounds, cornerRadius: radius).cgPath
        } else if indexPath.row == 0 {
            layer.path = UIBezierPath(roundedRect: cell.bounds, byRoundingCorners: [.topLeft, .topRight], cornerRadii: CGSize(width: radius, height: radius)).cgPath
            addSeparator = true
        } else if indexPath.row == rows {
            layer.path = UIBezierPath(roundedRect: cell.bounds, byRoundingCorners: [.bottomLeft, .bottomRight], cornerRadii: CGSize(width: radius, height: radius)).cgPath
        } else {
            layer.path = UIBezierPath(rect: cell.bounds).cgPath
            addSeparator = true
        }

        cell.mask = UIView(frame: cell.bounds)
        cell.mask?.layer.insertSublayer(layer, at: 0)
        if addSeparator == true {
            let separator: CGFloat = 1.0 / UIScreen.main.scale
            let cellSeparator = CALayer()
            cellSeparator.frame = CGRect(x: self.separatorInset.left, y: cell.bounds.size.height - separator, width: cell.bounds.size.width - self.separatorInset.left, height: separator)
            cellSeparator.backgroundColor = self.separatorColor?.cgColor
            cell.layer.addSublayer(cellSeparator)
        }
        cell.mask?.layer.masksToBounds = true
        cell.clipsToBounds = true
    }
}

public extension UITableView {

    /**
    Convenience method to register UITableViewCell for UITableView

    - parameters:
        - cell: T.Type
    */
    func register<T: UITableViewCell>(cell: T.Type) {
        self.register(cell, forCellReuseIdentifier: cell.identifier)
    }

    /**
    Convenience method to dequeue UITableViewCell for UITableView

    - returns:
    T

    - parameters:
        - cell: T.Type
        - for: IndexPath

    */
    func dequeue<T: UITableViewCell>(cell: T.Type, for indexPath: IndexPath) -> T {
        return self.dequeueReusableCell(withIdentifier: cell.identifier, for: indexPath) as! T
    }

    /**
    Convenience method to register UITableViewHeaderFooterView for UITableView

    - parameters:
        - headerFooter: T.Type
    */
    func register<T: UITableViewHeaderFooterView>(headerFooter: T.Type) {
        self.register(headerFooter, forHeaderFooterViewReuseIdentifier: headerFooter.identifier)
    }

    /**
    Convenience method to dequeue UITableViewHeaderFooterView for UITableView

    - returns:
    T

    - parameters:
        -headerFooter: T.Type

    */
    func dequeue<T: UITableViewHeaderFooterView>(headerFooter: T.Type) -> T {
        return self.dequeueReusableHeaderFooterView(withIdentifier: headerFooter.identifier) as! T
    }

    /**
    Convenience method to register UITableViewCell for UITableView

    - parameters:
        - nib: T.Type

    */
    func register<T: UITableViewCell>(nib: T.Type) {
        let bundle = Bundle(for: T.self)
        let uiNib = UINib(nibName: nib.nibName, bundle: bundle)
        self.register(uiNib, forCellReuseIdentifier: nib.nibName)
    }

    /**
        Convenience method to register UITableViewHeaderFooterView for UITableView

        - parameters:
            -headerFooterNib: T.Type

    */
    func register<T: UITableViewHeaderFooterView>(headerFooterNib: T.Type) {
        let bundle = Bundle(for: T.self)
        let uiNib = UINib(nibName: headerFooterNib.nibName, bundle: bundle)
        self.register(uiNib, forHeaderFooterViewReuseIdentifier: headerFooterNib.nibName)
    }

}

public extension UITableView {

    /**
        Convenience method for selecting all rows in UITableView

        - parameters:
            - animated: Bool default = false
            - forwardToDelegate: Bool default = false
    */
    func selectAllRows(animated: Bool = false, forwardToDelegate: Bool = false) {
        for section in 0..<self.numberOfSections {
            for row in 0..<self.numberOfRows(inSection: section) {
                let indexPath = IndexPath(row: row, section: section)
                if forwardToDelegate { _ = self.delegate?.tableView?(self, willSelectRowAt: indexPath) }
                self.selectRow(at: indexPath, animated: animated, scrollPosition: .none)
                if forwardToDelegate { self.delegate?.tableView?(self, didSelectRowAt: indexPath) }
            }
        }
    }

    /**
        Convenience method for deselecting all rows in UITableView

        - parameters:
            - animated: Bool default = false
            - forwardToDelegate: Bool default = false
    */
    func deselectAllRows(animated: Bool = false, forwardToDelegate: Bool = false) {
        for section in 0..<self.numberOfSections {
            for row in 0..<self.numberOfRows(inSection: section) {
                let indexPath = IndexPath(row: row, section: section)
                if forwardToDelegate { _ = self.delegate?.tableView?(self, willDeselectRowAt: indexPath) }
                self.deselectRow(at: indexPath, animated: animated)
                if forwardToDelegate { self.delegate?.tableView?(self, didDeselectRowAt: indexPath) }
            }
        }
    }
}

public extension UITableView {

    func isLast(_ indexPath: IndexPath) -> Bool {
        return (self.numberOfSections == (indexPath.section + 1)) && (self.numberOfRows(inSection: indexPath.section) == (indexPath.row + 1))
    }

    func isLastInSection(_ indexPath: IndexPath) -> Bool {
        return self.numberOfRows(inSection: indexPath.section) == (indexPath.row + 1)
    }

}

#endif
