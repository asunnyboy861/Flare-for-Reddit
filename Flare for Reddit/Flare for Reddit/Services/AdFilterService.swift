import Foundation

struct AdFilterService: Sendable {
    static let adKeywords: Set<String> = [
        "promoted", "sponsored", "advertisement", "ad",
        "promoted_by", "is_promoted", "promoted_display"
    ]

    static func filter(_ posts: [Post]) -> [Post] {
        posts.filter { post in
            !isAd(post)
        }
    }

    static func isAd(_ post: Post) -> Bool {
        if post.domain.contains("ad.") { return true }
        if post.domain.contains("doubleclick.net") { return true }
        if post.author == "reddit_ads" { return true }
        if post.title.lowercased().contains("[promoted]") { return true }
        if post.title.lowercased().contains("[sponsored]") { return true }
        if post.linkFlairText?.lowercased() == "promoted" { return true }
        return false
    }

    static func filterPostData(_ rawData: [String: Any]) -> Bool {
        if let promoted = rawData["promoted"] as? Bool, promoted { return true }
        if let isSponsored = rawData["is_sponsored"] as? Bool, isSponsored { return true }
        if let promotedBy = rawData["promoted_by"] as? String, !promotedBy.isEmpty { return true }
        if let author = rawData["author"] as? String, author == "reddit_ads" { return true }
        return false
    }
}
