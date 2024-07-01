#if canImport(UIKit)
import UIKit

@IBDesignable
open class ExpandingTableView: UITableView {

	@IBInspectable var showEmptyHeaders: Bool = false
	@IBInspectable var showEmptyFooters: Bool = false
	@IBInspectable var adjustForContentInset: Bool = false

	@IBOutlet open weak var heightConstraint: NSLayoutConstraint?

	public override init(frame: CGRect, style: UITableView.Style) {
		super.init(frame: frame, style: style)
		self.configure()
	}

	public required init?(coder: NSCoder) {
		super.init(coder: coder)
		self.configure()
	}

	fileprivate func configure() {
        if #available(iOS 15.0, *) {
            self.sectionHeaderTopPadding = 0.0
        }
	}

	override open func reloadData() {
		self.reloadHeight()
		super.reloadData()
	}

	open func reloadHeight() {

		guard let heightConstraint: NSLayoutConstraint = self.heightConstraint, heightConstraint.priority.rawValue < 1000 else { return }

		var height: CGFloat = 0.0

		for section: Int in 0..<(self.dataSource?.numberOfSections?(in: self) ?? 1) {

			guard ((self.dataSource?.tableView(self, numberOfRowsInSection: section) ?? 0) > 0) || self.showEmptyHeaders || self.showEmptyFooters else { continue }

			let sectionHeaderHeight: CGFloat = (self.delegate?.tableView?(self, heightForHeaderInSection: section)) ?? self.sectionHeaderHeight
			height += sectionHeaderHeight

			if (self.dataSource?.tableView(self, numberOfRowsInSection: section) ?? 0) == 0 && !self.showEmptyHeaders {
				height -= (sectionHeaderHeight)
			}

			let sectionFooterHeight: CGFloat = (self.delegate?.tableView?(self, heightForFooterInSection: section)) ?? self.sectionFooterHeight
			height += sectionFooterHeight

			if (self.dataSource?.tableView(self, numberOfRowsInSection: section) ?? 0) == 0 && !self.showEmptyFooters {
				height -= (sectionFooterHeight)
			}

			for row in 0..<(self.dataSource?.tableView(self, numberOfRowsInSection: section) ?? 0) {
				let rowHeight: CGFloat = (self.delegate?.tableView?(self, heightForRowAt: IndexPath(row: row, section: section))) ?? self.rowHeight
				height += rowHeight
			}
		}

		if self.adjustForContentInset {
			height += self.contentInset.top + self.contentInset.bottom
		}

		heightConstraint.constant = height
		self.setNeedsLayout()
	}

	override open func layoutSubviews() {
		super.layoutSubviews()
		self.isScrollEnabled = (self.contentSize.height > self.frame.height)
	}
}
#endif
