import Foundation

struct User: Codable, Sendable {
    let id: String
    let name: String
    let iconImg: String
    let linkKarma: Int
    let commentKarma: Int
    let totalKarma: Int
    let isGold: Bool
    let createdAt: TimeInterval

    enum CodingKeys: String, CodingKey {
        case id, name
        case iconImg = "icon_img"
        case linkKarma = "link_karma"
        case commentKarma = "comment_karma"
        case totalKarma = "total_karma"
        case isGold = "is_gold"
        case createdAt = "created_utc"
    }

    var displayLinkKarma: String {
        if linkKarma >= 1000 {
            return String(format: "%.1fk", Double(linkKarma) / 1000.0)
        }
        return "\(linkKarma)"
    }

    var displayCommentKarma: String {
        if commentKarma >= 1000 {
            return String(format: "%.1fk", Double(commentKarma) / 1000.0)
        }
        return "\(commentKarma)"
    }
}
