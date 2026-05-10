import Foundation
import Alamofire

final class RedditAPIService: @unchecked Sendable {
    static let shared = RedditAPIService()

    private let authService = AuthService.shared
    private let rateLimiter = RateLimiter(maxRequests: 95, perInterval: 60)
    private let cacheService = CacheService.shared

    private init() {}

    private func authenticatedHeaders() async throws -> HTTPHeaders {
        let token = try await authService.getValidToken()
        return HTTPHeaders([
            "Authorization": "Bearer \(token)",
            "User-Agent": "FlareForReddit/1.0 (by /u/FlareForReddit)"
        ])
    }

    private func publicHeaders() -> HTTPHeaders {
        HTTPHeaders([
            "User-Agent": "FlareForReddit/1.0 (by /u/FlareForReddit)"
        ])
    }

    func getFeed(subreddit: String? = nil, sort: SortType = .hot, after: String? = nil) async throws -> FeedResult {
        try await rateLimiter.waitIfNeeded()

        let path = subreddit.map { "/r/\($0)/\(sort.rawValue)" } ?? "/\(sort.rawValue)"
        var parameters: [String: String] = ["limit": "25", "raw_json": "1"]
        if let after { parameters["after"] = after }

        let headers: HTTPHeaders
        let baseURL: String

        if authService.isAuthenticated {
            headers = try await authenticatedHeaders()
            baseURL = RedditConfig.baseURL
        } else {
            headers = publicHeaders()
            baseURL = RedditConfig.publicBaseURL
        }

        let response = try await AF.request(
            "\(baseURL)\(path)",
            parameters: parameters,
            headers: headers
        ).serializingDecodable(RedditResponse.self).value

        let posts = parsePosts(from: response)
        let filteredPosts = AdFilterService.filter(posts)

        if !filteredPosts.isEmpty {
            cacheService.savePosts(filteredPosts)
        }

        let afterCursor = extractAfter(from: response)
        return FeedResult(posts: filteredPosts, after: afterCursor, before: nil)
    }

    func getPostComments(subreddit: String, postId: String) async throws -> (Post, [Comment]) {
        try await rateLimiter.waitIfNeeded()

        let path = "/r/\(subreddit)/comments/\(postId)"
        let parameters: [String: String] = ["limit": "50", "raw_json": "1", "sort": "best"]

        let headers: HTTPHeaders
        let baseURL: String

        if authService.isAuthenticated {
            headers = try await authenticatedHeaders()
            baseURL = RedditConfig.baseURL
        } else {
            headers = publicHeaders()
            baseURL = RedditConfig.publicBaseURL
        }

        let response = try await AF.request(
            "\(baseURL)\(path)",
            parameters: parameters,
            headers: headers
        ).serializingData().value

        guard let json = try? JSONSerialization.jsonObject(with: response) as? [[String: Any]],
              json.count >= 2 else {
            throw RedditError.invalidResponse
        }

        let post = try parseSinglePost(from: json[0])
        let comments = try parseComments(from: json[1])
        return (post, comments)
    }

    func search(query: String, type: String = "link", sort: SortType = .relevance, after: String? = nil) async throws -> FeedResult {
        try await rateLimiter.waitIfNeeded()

        var parameters: [String: String] = [
            "q": query,
            "type": type,
            "sort": sort == .relevance ? "relevance" : sort.rawValue,
            "limit": "25",
            "raw_json": "1"
        ]
        if let after { parameters["after"] = after }

        let headers: HTTPHeaders
        let baseURL: String

        if authService.isAuthenticated {
            headers = try await authenticatedHeaders()
            baseURL = RedditConfig.baseURL
        } else {
            headers = publicHeaders()
            baseURL = RedditConfig.publicBaseURL
        }

        let response = try await AF.request(
            "\(baseURL)/search",
            parameters: parameters,
            headers: headers
        ).serializingDecodable(RedditResponse.self).value

        let posts = parsePosts(from: response)
        let filteredPosts = AdFilterService.filter(posts)
        let afterCursor = extractAfter(from: response)
        return FeedResult(posts: filteredPosts, after: afterCursor, before: nil)
    }

    func vote(id: String, direction: Post.VoteState) async throws {
        guard authService.isAuthenticated else { throw RedditError.unauthorized }
        try await rateLimiter.waitIfNeeded()

        let headers = try await authenticatedHeaders()
        let dir: Int = direction == .upvote ? 1 : direction == .downvote ? -1 : 0

        _ = try await AF.request(
            "\(RedditConfig.baseURL)/api/vote",
            method: .post,
            parameters: ["id": "t3_\(id)", "dir": dir],
            headers: headers
        ).serializingData().value
    }

    func save(id: String, save: Bool) async throws {
        guard authService.isAuthenticated else { throw RedditError.unauthorized }
        try await rateLimiter.waitIfNeeded()

        let headers = try await authenticatedHeaders()
        let endpoint = save ? "/api/save" : "/api/unsave"

        _ = try await AF.request(
            "\(RedditConfig.baseURL)\(endpoint)",
            method: .post,
            parameters: ["id": "t3_\(id)"],
            headers: headers
        ).serializingData().value
    }

    func submitPost(subreddit: String, title: String, text: String) async throws {
        guard authService.isAuthenticated else { throw RedditError.unauthorized }
        try await rateLimiter.waitIfNeeded()

        let headers = try await authenticatedHeaders()

        _ = try await AF.request(
            "\(RedditConfig.baseURL)/api/submit",
            method: .post,
            parameters: [
                "sr": subreddit,
                "title": title,
                "text": text,
                "kind": "self"
            ],
            headers: headers
        ).serializingData().value
    }

    func getSubscribedSubreddits(after: String? = nil) async throws -> [Subreddit] {
        guard authService.isAuthenticated else { return [] }
        try await rateLimiter.waitIfNeeded()

        let headers = try await authenticatedHeaders()
        var parameters: [String: String] = ["limit": "50", "raw_json": "1"]
        if let after { parameters["after"] = after }

        let response = try await AF.request(
            "\(RedditConfig.baseURL)/subreddits/mine/subscriber",
            parameters: parameters,
            headers: headers
        ).serializingDecodable(SubredditListing.self).value

        return response.data.children.map(\.data)
    }

    private func parsePosts(from response: RedditResponse) -> [Post] {
        response.data.children.compactMap { child -> Post? in
            guard child.kind == "t3" else { return nil }
            return child.data
        }
    }

    private func extractAfter(from response: RedditResponse) -> String? {
        response.data.after
    }

    private func parseSinglePost(from json: [String: Any]) throws -> Post {
        guard let kind = json["kind"] as? String,
              kind == "Listing",
              let data = json["data"] as? [String: Any],
              let children = data["children"] as? [[String: Any]],
              let firstChild = children.first,
              let postData = firstChild["data"] as? [String: Any] else {
            throw RedditError.invalidResponse
        }
        return try parsePostData(postData)
    }

    private func parseComments(from json: [String: Any]) throws -> [Comment] {
        guard let data = json["data"] as? [String: Any],
              let children = data["children"] as? [[String: Any]] else {
            return []
        }
        return children.compactMap { parseCommentRecursive($0) }
    }

    private func parseCommentRecursive(_ json: [String: Any], depth: Int = 0) -> Comment? {
        guard let kind = json["kind"] as? String, kind == "t1",
              let data = json["data"] as? [String: Any] else { return nil }

        let replies: [Comment]? = {
            guard let repliesData = data["replies"] as? [String: Any] else { return nil }
            guard let repliesChildren = repliesData["data"] as? [String: Any],
                  let children = repliesChildren["children"] as? [[String: Any]] else { return nil }
            return children.compactMap { parseCommentRecursive($0, depth: depth + 1) }
        }()

        return Comment(
            id: data["id"] as? String ?? "",
            author: data["author"] as? String ?? "[deleted]",
            body: data["body"] as? String ?? "",
            score: data["score"] as? Int ?? 0,
            createdUTC: data["created_utc"] as? Double ?? 0,
            parentId: data["parent_id"] as? String ?? "",
            depth: data["depth"] as? Int ?? depth,
            isSubmitter: data["is_submitter"] as? Bool ?? false,
            permalink: data["permalink"] as? String ?? "",
            voteState: .none,
            isCollapsed: false,
            replies: replies
        )
    }

    private func parsePostData(_ data: [String: Any]) throws -> Post {
        let resolvedImageURL: String? = {
            guard let preview = data["preview"] as? [String: Any],
                  let images = preview["images"] as? [[String: Any]],
                  let firstImage = images.first,
                  let source = firstImage["source"] as? [String: Any],
                  let url = source["url"] as? String else { return nil }
            return url
        }()

        let resolvedVideoURL: String? = {
            guard let media = data["media"] as? [String: Any],
                  let redditVideo = media["reddit_video"] as? [String: Any],
                  let url = redditVideo["fallback_url"] as? String else { return nil }
            return url
        }()

        return Post(
            id: data["id"] as? String ?? "",
            title: data["title"] as? String ?? "",
            author: data["author"] as? String ?? "[deleted]",
            subreddit: data["subreddit"] as? String ?? "",
            selftext: data["selftext"] as? String ?? "",
            url: data["url"] as? String ?? "",
            thumbnailURL: data["thumbnail"] as? String,
            imageURL: resolvedImageURL,
            score: data["score"] as? Int ?? 0,
            numComments: data["num_comments"] as? Int ?? 0,
            createdUTC: data["created_utc"] as? Double ?? 0,
            isVideo: data["is_video"] as? Bool ?? false,
            videoURL: resolvedVideoURL,
            linkFlairText: data["link_flair_text"] as? String,
            isSelf: data["is_self"] as? Bool ?? true,
            domain: data["domain"] as? String ?? "",
            over18: data["over_18"] as? Bool ?? false,
            permalink: data["permalink"] as? String ?? "",
            voteState: .none,
            isSaved: data["saved"] as? Bool ?? false
        )
    }
}

struct RedditResponse: Codable {
    let kind: String
    let data: RedditResponseData
}

struct RedditResponseData: Codable {
    let after: String?
    let dist: Int?
    let children: [RedditChild]
}

struct RedditChild: Codable {
    let kind: String
    let data: Post
}

extension SortType {
    static let relevance = SortType(rawValue: "relevance") ?? .hot
}
