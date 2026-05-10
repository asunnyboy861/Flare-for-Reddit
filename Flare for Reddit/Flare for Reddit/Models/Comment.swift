import Foundation

struct Comment: Identifiable, Codable, Sendable {
    let id: String
    let author: String
    let body: String
    let score: Int
    let createdUTC: TimeInterval
    let parentId: String
    let depth: Int
    let isSubmitter: Bool
    let permalink: String
    var voteState: Post.VoteState
    var isCollapsed: Bool
    var replies: [Comment]?

    enum CodingKeys: String, CodingKey {
        case id
        case author
        case body
        case score
        case createdUTC = "created_utc"
        case parentId = "parent_id"
        case depth
        case isSubmitter = "is_submitter"
        case permalink
        case voteState
        case isCollapsed
        case replies
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

struct CommentListing: Codable, Sendable {
    let kind: String
    let data: CommentListingData

    struct CommentListingData: Codable, Sendable {
        let children: [CommentChild]
    }

    struct CommentChild: Codable, Sendable {
        let kind: String
        let data: CommentData
    }

    struct CommentData: Codable, Sendable {
        let id: String
        let author: String
        let body: String
        let score: Int
        let createdUTC: TimeInterval
        let parentId: String
        let depth: Int
        let isSubmitter: Bool
        let permalink: String
        let replies: CommentListing?

        enum CodingKeys: String, CodingKey {
            case id, author, body, score, depth, permalink, replies
            case createdUTC = "created_utc"
            case parentId = "parent_id"
            case isSubmitter = "is_submitter"
        }
    }
}
