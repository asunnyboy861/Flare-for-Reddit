import Foundation

struct Post: Identifiable, Codable, Hashable, Sendable {
    let id: String
    let title: String
    let author: String
    let subreddit: String
    let selftext: String
    let url: String
    let thumbnailURL: String?
    let imageURL: String?
    var score: Int
    let numComments: Int
    let createdUTC: TimeInterval
    let isVideo: Bool
    let videoURL: String?
    let linkFlairText: String?
    let isSelf: Bool
    let domain: String
    let over18: Bool
    let permalink: String
    var voteState: VoteState
    var isSaved: Bool

    enum VoteState: String, Codable, Sendable {
        case none = ""
        case upvote = "1"
        case downvote = "-1"
    }

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case author
        case subreddit
        case selftext
        case url
        case thumbnailURL = "thumbnail"
        case imageURL
        case score
        case numComments = "num_comments"
        case createdUTC = "created_utc"
        case isVideo = "is_video"
        case videoURL
        case linkFlairText = "link_flair_text"
        case isSelf = "is_self"
        case domain
        case over18 = "over_18"
        case permalink
        case voteState
        case isSaved
    }

    var timeAgo: String {
        let interval = Date().timeIntervalSince1970 - createdUTC
        if interval < 60 { return "just now" }
        if interval < 3600 { return "\(Int(interval / 60))m" }
        if interval < 86400 { return "\(Int(interval / 3600))h" }
        if interval < 2592000 { return "\(Int(interval / 86400))d" }
        return "\(Int(interval / 2592000))mo"
    }

    var displayScore: String {
        if score >= 1000 {
            return String(format: "%.1fk", Double(score) / 1000.0)
        }
        return "\(score)"
    }
}

struct PostListing: Codable, Sendable {
    let kind: String
    let data: PostListingData

    struct PostListingData: Codable, Sendable {
        let after: String?
        let dist: Int?
        let children: [PostChild]
    }

    struct PostChild: Codable, Sendable {
        let kind: String
        let data: Post
    }
}
