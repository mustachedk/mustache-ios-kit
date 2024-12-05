import UIKit

public extension UIViewController {
    func addChild(_ childController: UIViewController, in containerView: UIView) {
        self.addChild(childController)
        containerView.embed(childController.view)
        childController.didMove(toParent: self)
    }
}

public extension UIView {
    func embed(_ childView: UIView) {
        self.addSubview(childView)
        childView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            childView.topAnchor.constraint(equalTo: self.topAnchor),
            childView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            childView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            childView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
        ])
    }
}
