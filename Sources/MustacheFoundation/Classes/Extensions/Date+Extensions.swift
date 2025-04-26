
import Foundation

public extension String {

    func date(_ format: String, utc: Bool = true) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        dateFormatter.timeZone = utc ? TimeZone(identifier: "UTC") : TimeZone.current
        return dateFormatter.date(from: self)
    }
}

public extension Date {
    
    var weekday: Int {
        // https://stackoverflow.com/a/65498893/1366083
        let weekday = (Calendar.daDK.component(.weekday, from: self) - Calendar.daDK.firstWeekday + 7) % 7 + 1
        return weekday
    }
    
    var weekday2: Int {
        let weekday = Calendar.daDK.component(.weekday, from: self)
        if weekday == 1 {
            return 7
        } else {
            return weekday - 1
        }
    }
    
    static var nowSafe: Date {
        if #available(iOS 15, macOS 12, watchOS 8, *) {
            return self.now
        } else {
            return Date()
        }
    }
    
    var dayNumberOfMonth: Int {
        return Calendar.daDK.dateComponents([.day], from: self).day ?? 0
    }
    
    var monthNumberOfYear: Int {
        return Calendar.daDK.dateComponents([.month], from: self).month ?? 0
    }
        
    func startOfMonth() -> Date {
        let startOfDay = Calendar.daDK.startOfDay(for: self)
        let components = Calendar.daDK.dateComponents([.year, .month], from: startOfDay)
        let startOfMonth = Calendar.daDK.date(from: components)
        return startOfMonth ?? self
    }
    
    func endOfMonth() -> Date {
        let startOfMonth = self.startOfMonth()
        let endOfMonth = Calendar.current.date(byAdding: DateComponents(month: 1, day: -1), to: startOfMonth)
        return endOfMonth ?? self
    }
    
    var isInPast: Bool { return .nowSafe > self }
    
    var isInFuture: Bool { return .nowSafe < self }
    
    func format(_ format: String, utc: Bool = true) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        dateFormatter.timeZone = utc ? TimeZone(identifier: "UTC") : TimeZone.current
        return dateFormatter.string(from: self)
    }
    
    func within(component: Calendar.Component, value: UInt) -> Bool {
        return Calendar.daDK.within(self, within: component, value: value)
    }
    
}

//@available(iOS 13.0, macOS 15, *)
//extension Date: Strideable {
//
//    public func advanced(by n: Int) -> Date {
//         return Calendar.current.date(byAdding: .day, value: n, to: self) ?? self
//     }
// 
//     public func distance(to other: Date) -> Int {
//         return Calendar.current.dateComponents([.day], from: other, to: self).day ?? 0
//     }
// }
