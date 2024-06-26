import UIKit
//Xib
public extension UIView {

    /**
    Convenience method for configuring Xib views,

    - returns:
    UIView?

    `@IBOutlet var contentView: UIView!`

    Create an outlet in the swift file called *contentView and bind it to main view of the Xib file.
    Make sure to call `self.contentView = self.configureNibView()` in all constructors


    */
    func configureNibView() -> UIView? {
        guard let nibView = loadViewFromNib() else { return nil }

        self.addSubview(nibView)

        nibView.translatesAutoresizingMaskIntoConstraints = false
        nibView.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        nibView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        nibView.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        nibView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true

        return nibView
    }

    /**
    Convenience method for configuring Xib views,

    - returns:
    UIView?

    Used with `func configureNibView()`

    */
    func loadViewFromNib() -> UIView? {
        let nibName = type(of: self).nibName
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: nibName, bundle: bundle)
        let objects = nib.instantiate(withOwner: self, options: nil)
        let view = objects.first as? UIView
        return view
    }

    /// Convenience nibName for UIView
    class var nibName: String {
        return String(describing: self)
    }
}

//Hierarchy
public extension UIView {

    /**
    Convenience method for addind multiple subviews in one line

    - parameters:
        - views: UIView...

    */
    func addSubviews(_ views: UIView...) {
        views.forEach { view in self.addSubview(view) }
    }

    /// Top view in the hierarchy
    var rootView: UIView {
        if let view = self.superview {
            return view.rootView
        } else {
            return self
        }
    }

    /**
    This is a function to get subViews of a view of a particular type

    - returns:
    [T]

    - parameters:
        - type: T.Type

    */
    func subViews<T: UIView>(type: T.Type) -> [T] {
        var all = [T]()
        for view in self.subviews {
            if let aView = view as? T {
                all.append(aView)
            }
        }
        return all
    }

    /**
    This is a function to get subViews of a particular type from view recursively. It would look recursively in all subviews and return back the subviews of the type T

    - returns:
    [T]

    - parameters:
        - type: T.Type

    */
    func allSubViewsOf<T: UIView>(type: T.Type) -> [T] {
        var all = [T]()

        func getSubview(view: UIView) {
            if let aView = view as? T {
                all.append(aView)
            }
            guard view.subviews.count > 0 else { return }
            view.subviews.forEach { getSubview(view: $0) }
        }

        getSubview(view: self)
        return all
    }
    
    func parentView<T: UIView>(ofType: T.Type) -> T? {
        let parentView: UIView? = self.superview
        while parentView != nil {
            if let parentView = parentView as? T {
                return parentView
            } else {
                return self.parentView(ofType: ofType)
            }
        }
        return nil
    }

    /**
    This is a function to get a UIViewController of a particular type from view recursively. It would look in the responder chain and return back the UIViewController of the type T

    - returns:
    T?

    */
    func parentViewController<T: UIViewController>() -> T? {
        var parentResponder: UIResponder? = self
        while parentResponder != nil {
            parentResponder = parentResponder!.next
            if let viewController = parentResponder as? T {
                return viewController
            }
        }
        return nil
    }
}

//Autolayout
public extension UIView {

    /// safeInsets
    var safeInsets: UIEdgeInsets {
        if #available(iOS 11.0, *) {
            return self.safeAreaInsets
        } else {
            return .zero
        }
    }

}
//Image
public extension UIView {

    func snapshot(opaque: Bool = false) -> UIImage? {
      UIGraphicsBeginImageContextWithOptions(self.bounds.size, opaque, UIScreen.main.scale)
      guard let context = UIGraphicsGetCurrentContext() else { return nil }
      self.layer.render(in: context)
      let image = UIGraphicsGetImageFromCurrentImageContext()
      UIGraphicsEndImageContext()

      guard let imageData = image?.pngData() else { return nil }
      return UIImage(data: imageData)
  }
}

public extension UIView {

    var isVisible: Bool {
        return !self.isHidden && self.alpha > 0
    }
    
    var isInBounds: Bool {
        return isInBounds(view: self, inView: self.superview)
    }

    fileprivate func isInBounds(view: UIView, inView: UIView?) -> Bool {
        guard let inView = inView else { return true }
        let viewFrame = inView.convert(view.bounds, from: view)
        if viewFrame.intersects(inView.bounds) {
            return isInBounds(view: view, inView: inView.superview)
        }
        return false
    }
}

enum LayoutAnchor {
    case top(to: NSLayoutYAxisAnchor, constant: CGFloat? = nil)
    case bottom(to: NSLayoutYAxisAnchor, constant: CGFloat? = nil)
    case leading(to: NSLayoutXAxisAnchor, constant: CGFloat? = nil)
    case trailing(to: NSLayoutXAxisAnchor, constant: CGFloat? = nil)
    case centerX(to: NSLayoutXAxisAnchor, constant: CGFloat? = nil)
    case centerY(to: NSLayoutYAxisAnchor, constant: CGFloat? = nil)
    case height(constant: CGFloat)
    case heightAnchor(to: NSLayoutDimension)
    case width(constant: CGFloat)
    case widthAnchor(to: NSLayoutDimension)
    case size(CGSize)
    case fill(padding: UIEdgeInsets? = nil)
    case fillInSafeArea(padding: UIEdgeInsets? = nil)
    case centerInSuperview(rect: CGRect = .zero)
}

extension UIView {

    func addSubview(_ subview: UIView, anchors: [LayoutAnchor]) {
        subview.translatesAutoresizingMaskIntoConstraints = false
        addSubview(subview)

        anchors.forEach { anchor in
            switch anchor {
                case .top(let anchor, let constant):
                    subview.topAnchor.constraint(equalTo: anchor, constant: constant ?? 0).isActive = true
                case .bottom(let anchor, let constant):
                    subview.bottomAnchor.constraint(equalTo: anchor, constant: -(constant ?? 0)).isActive = true
                case .leading(let anchor, let constant):
                    subview.leadingAnchor.constraint(equalTo: anchor, constant: constant ?? 0).isActive = true
                case .trailing(let anchor, let constant):
                    subview.trailingAnchor.constraint(equalTo: anchor, constant: -(constant ?? 0)).isActive = true
                case .centerX(let anchor, let constant):
                    subview.centerXAnchor.constraint(equalTo: anchor, constant: constant ?? 0).isActive = true
                case .centerY(let anchor, let constant):
                    subview.centerYAnchor.constraint(equalTo: anchor, constant: constant ?? 0).isActive = true
                case .height(let constant):
                    subview.heightAnchor.constraint(equalToConstant: constant).isActive = true
                case .heightAnchor(to: let dimension):
                    subview.heightAnchor.constraint(equalTo: dimension).isActive = true
                case .width(let constant):
                    subview.widthAnchor.constraint(equalToConstant: constant).isActive = true
                case .widthAnchor(to: let dimension):
                    subview.widthAnchor.constraint(equalTo: dimension).isActive = true
                case .fill(padding: let padding):
                    subview.topAnchor.constraint(equalTo: self.topAnchor, constant: padding?.top ?? 0).isActive = true
                    subview.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: padding?.left ?? 0).isActive = true
                    subview.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -(padding?.right ?? 0)).isActive = true
                    subview.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -(padding?.bottom ?? 0)).isActive = true
                case .fillInSafeArea(padding: let padding):
                    subview.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor, constant: padding?.top ?? 0).isActive = true
                    subview.leadingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.leadingAnchor, constant: padding?.left ?? 0).isActive = true
                    subview.trailingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.trailingAnchor, constant: -(padding?.right ?? 0)).isActive = true
                    subview.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor, constant: -(padding?.bottom ?? 0)).isActive = true
                case .centerInSuperview(rect: let rect):
                    subview.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: rect.origin.y).isActive = true
                    subview.centerXAnchor.constraint(equalTo: self.centerXAnchor, constant: rect.origin.x).isActive = true
                    subview.heightAnchor.constraint(equalToConstant: rect.height).isActive = true
                    subview.widthAnchor.constraint(equalToConstant: rect.width).isActive = true
                case .size(let size):
                    subview.widthAnchor.constraint(equalToConstant: size.width).isActive = true
                    subview.heightAnchor.constraint(equalToConstant: size.height).isActive = true
            }
        }
    }
}
