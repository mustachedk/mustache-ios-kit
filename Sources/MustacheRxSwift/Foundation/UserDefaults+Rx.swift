
import Foundation

#if canImport(RxCocoa)

import RxSwift
import RxCocoa

public extension UserDefaults {

    func observeCodable<T: Codable>(_ type: T.Type, _ keyPath: String) -> RxObservable<T?> {

        let string = "\(UserDefaults.didChangeNotification.rawValue)-\(keyPath)"
        let name = NSNotification.Name(rawValue: string)

        return NotificationCenter.default.rx.notification(name).map { [keyPath]_ -> T? in
            guard let data = self.value(forKey: keyPath) as? Data else { return nil }
            let decoder = JSONDecoder()
            let loaded = try? decoder.decode([T].self, from: data).first
            return loaded
        }
    }

}

#endif
