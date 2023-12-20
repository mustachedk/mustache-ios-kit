import Foundation

public extension Substring {
    
    var intValue: Int? { return Int(String(self)) }
    
    var string: String { return String(self) }
}

public extension String {

    func capitalizingFirstLetter() -> String {
        let first = String(self.prefix(1)).capitalized
        let other = String(self.dropFirst())
        return first + other
    }

    mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    } 
    
    func stripOutHtml() -> String? {
        do {
            guard let data = self.data(using: .unicode) else {
                return nil
            }
            let options: [NSAttributedString.DocumentReadingOptionKey : Any] = [.documentType: NSAttributedString.DocumentType.html, .characterEncoding: String.Encoding.utf8.rawValue]
            let attributed = try NSAttributedString(data: data,
                                                    options: options,
                                                    documentAttributes: nil)
            return attributed.string
        } catch {
            return nil
        }
    }
}

public extension String {

    var localized: String { return NSLocalizedString(self, comment: "") }

    var gif: Data {
        if let path = Bundle.main.path(forResource: self, ofType: "gif") {
            let url = URL(fileURLWithPath: path)
            return (try? Data(contentsOf: url)) ?? Data()
        }
        return Data()
    }

    var urlEscaped: String { return addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)! }

    var utf8Encoded: Data { return data(using: .utf8)! }

    subscript(bounds: CountableClosedRange<Int>) -> String {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return String(self[start...end])
    }

    subscript(bounds: CountableRange<Int>) -> String {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return String(self[start..<end])
    }

    subscript(bounds: PartialRangeUpTo<Int>) -> String {
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return String(self[startIndex..<end])
    }

    subscript(bounds: PartialRangeThrough<Int>) -> String {
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return String(self[startIndex...end])
    }

    subscript(bounds: CountablePartialRangeFrom<Int>) -> String {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        return String(self[start..<endIndex])
    }
}

public extension String {

    func separate(every stride: Int = 4, with separator: Character = " ") -> String {
        return String(enumerated().map { $0 > 0 && $0 % stride == 0 ? [separator, $1] : [$1] }.joined())
    }

    var orNil: String? {
        return (self.count > 0) ? self : nil
    }
}
