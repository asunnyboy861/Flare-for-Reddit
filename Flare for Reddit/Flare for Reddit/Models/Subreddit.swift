import Foundation

struct Subreddit: Identifiable, Codable, Hashable, Sendable {
    let id: String
    let name: String
    let displayName: String
    let title: String
    let publicDescription: String
    let subscribers: Int
    let iconURL: String?
    let bannerURL: String?
    let over18: Bool
    let isSubscribed: Bool

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case displayName = "display_name"
        case title
        case publicDescription = "public_description"
        case subscribers
        case iconURL = "icon_img"
        case bannerURL = "banner_img"
        case over18 = "over18"
        case isSubscribed = "user_is_subscriber"
    }

    var displaySubscribers: String {
        if subscribers >= 1000000 {
            return String(format: "%.1fM", Double(subscribers) / 1000000.0)
        }
        if subscribers >= 1000 {
            return String(format: "%.1fk", Double(subscribers) / 1000.0)
        }
        return "\(subscribers)"
    }
}

struct SubredditListing: Codable, Sendable {
    let kind: String
    let data: SubredditListingData

    struct SubredditListingData: Codable, Sendable {
        let children: [SubredditChild]
        let after: String?
    }

    struct SubredditChild: Codable, Sendable {
        let kind: String
        let data: Subreddit
    }
}
