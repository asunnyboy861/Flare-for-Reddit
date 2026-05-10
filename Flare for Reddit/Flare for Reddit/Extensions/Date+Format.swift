import Foundation

extension Date {
    var timeAgoDisplay: String {
        let interval = Date().timeIntervalSince(self)
        if interval < 60 { return "just now" }
        if interval < 3600 { return "\(Int(interval / 60))m ago" }
        if interval < 86400 { return "\(Int(interval / 3600))h ago" }
        if interval < 2592000 { return "\(Int(interval / 86400))d ago" }
        if interval < 31536000 { return "\(Int(interval / 2592000))mo ago" }
        return "\(Int(interval / 31536000))y ago"
    }

    var shortDateString: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: self)
    }
}
