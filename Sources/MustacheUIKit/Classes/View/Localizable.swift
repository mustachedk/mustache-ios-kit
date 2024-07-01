#if canImport(UIKit)
import Foundation
import UIKit
import MustacheFoundation

public extension String {

    var configLocalized: String {
        if let localized = UserDefaults.standard.string(forKey: self) {
            return localized
        } else {
            return self.localized
        }
    }
}

open class LocalizableLabel: UILabel {

    @IBInspectable public var translationKey: String?

    override open func awakeFromNib() {
        super.awakeFromNib()
        self.updateLocalization()
        NotificationCenter.default.addObserver(self, selector: #selector(updateLocalization), name: .updatedTranslations, object: nil)
    }

    @objc
    fileprivate func updateLocalization(){
        if let key = self.translationKey, key != key.configLocalized {
            self.text = key.configLocalized
        }
    }
}

open class LocalizableButton: Button {

    @IBInspectable public var translationKey: String?

    override open func awakeFromNib() {
        super.awakeFromNib()
        self.updateLocalization()
        NotificationCenter.default.addObserver(self, selector: #selector(updateLocalization), name: .updatedTranslations, object: nil)
    }

    @objc
    fileprivate func updateLocalization(){
        if let key = self.translationKey, key != key.configLocalized {
            self.setTitle(key.configLocalized, for: UIControl.State())
        }
    }
}

open class LocalizableTextField: UITextField {

    @IBInspectable public var translationKey: String?

    @IBInspectable public var placeholderTranslationKey: String?

    override open func awakeFromNib() {
        super.awakeFromNib()
        self.updateLocalization()
        NotificationCenter.default.addObserver(self, selector: #selector(updateLocalization), name: .updatedTranslations, object: nil)
    }

    @objc
    fileprivate func updateLocalization(){
        if let key = self.translationKey, key != key.configLocalized {
            self.placeholder = key.configLocalized
        }
        if let placeholderTranslationKey = self.placeholderTranslationKey, placeholderTranslationKey != placeholderTranslationKey.configLocalized {
            self.placeholder = placeholderTranslationKey.configLocalized
        }
    }
}

open class LocalizableSearchBar: UISearchBar {

    @IBInspectable public var translationKey: String?

    override open func awakeFromNib() {
        super.awakeFromNib()
        self.updateLocalization()
        NotificationCenter.default.addObserver(self, selector: #selector(updateLocalization), name: .updatedTranslations, object: nil)
    }

    @objc
    fileprivate func updateLocalization(){
        if let key = self.translationKey, key != key.configLocalized {
            self.placeholder = key.configLocalized
        }
    }
}

public extension NSNotification.Name {

    static let updatedTranslations = NSNotification.Name(rawValue: "updatedTranslations")

}
#endif
