import Foundation
import GRDB

final class CacheService: @unchecked Sendable {
    static let shared = CacheService()

    private let dbQueue: DatabaseQueue

    private init() {
        let dbPath = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("flare_cache.sqlite").path
        var config = Configuration()
        config.prepareDatabase { db in
            try db.execute(sql: "PRAGMA journal_mode=WAL")
            try db.execute(sql: "PRAGMA synchronous=NORMAL")
        }
        dbQueue = try! DatabaseQueue(path: dbPath, configuration: config)
        try? createTables()
    }

    private func createTables() throws {
        try dbQueue.write { db in
            try db.create(table: "cached_posts", ifNotExists: true) { t in
                t.column("id", .text).primaryKey()
                t.column("title", .text).notNull()
                t.column("author", .text).notNull()
                t.column("subreddit", .text).notNull()
                t.column("selftext", .text).notNull().defaults(to: "")
                t.column("url", .text).notNull().defaults(to: "")
                t.column("thumbnailURL", .text)
                t.column("imageURL", .text)
                t.column("score", .integer).notNull().defaults(to: 0)
                t.column("numComments", .integer).notNull().defaults(to: 0)
                t.column("createdUTC", .double).notNull()
                t.column("isVideo", .boolean).notNull().defaults(to: false)
                t.column("videoURL", .text)
                t.column("linkFlairText", .text)
                t.column("isSelf", .boolean).notNull().defaults(to: true)
                t.column("domain", .text).notNull().defaults(to: "")
                t.column("over18", .boolean).notNull().defaults(to: false)
                t.column("permalink", .text).notNull().defaults(to: "")
                t.column("voteState", .text).notNull().defaults(to: "")
                t.column("isSaved", .boolean).notNull().defaults(to: false)
                t.column("cachedAt", .datetime).notNull()
            }

            try db.create(table: "cached_subreddits", ifNotExists: true) { t in
                t.column("id", .text).primaryKey()
                t.column("name", .text).notNull()
                t.column("displayName", .text).notNull()
                t.column("title", .text).notNull().defaults(to: "")
                t.column("publicDescription", .text).notNull().defaults(to: "")
                t.column("subscribers", .integer).notNull().defaults(to: 0)
                t.column("iconURL", .text)
                t.column("bannerURL", .text)
                t.column("over18", .boolean).notNull().defaults(to: false)
                t.column("isSubscribed", .boolean).notNull().defaults(to: false)
                t.column("cachedAt", .datetime).notNull()
            }
        }
    }

    func getCachedPosts(subreddit: String? = nil, sort: SortType = .hot) -> [Post]? {
        let ttl: TimeInterval = 30 * 60
        let cutoff = Date().addingTimeInterval(-ttl)

        return try? dbQueue.read { db -> [Post] in
            let rows = try Row.fetchAll(db, sql: "SELECT * FROM cached_posts WHERE cachedAt > ? ORDER BY createdUTC DESC LIMIT 50", arguments: [cutoff])
            return rows.compactMap { row -> Post? in
                Post(
                    id: row["id"],
                    title: row["title"],
                    author: row["author"],
                    subreddit: row["subreddit"],
                    selftext: row["selftext"],
                    url: row["url"],
                    thumbnailURL: row["thumbnailURL"],
                    imageURL: row["imageURL"],
                    score: row["score"],
                    numComments: row["numComments"],
                    createdUTC: row["createdUTC"],
                    isVideo: row["isVideo"],
                    videoURL: row["videoURL"],
                    linkFlairText: row["linkFlairText"],
                    isSelf: row["isSelf"],
                    domain: row["domain"],
                    over18: row["over18"],
                    permalink: row["permalink"],
                    voteState: Post.VoteState(rawValue: row["voteState"]) ?? .none,
                    isSaved: row["isSaved"]
                )
            }
        }
    }

    func savePosts(_ posts: [Post]) {
        try? dbQueue.write { db in
            for post in posts {
                try db.execute(sql: """
                    INSERT OR REPLACE INTO cached_posts (id, title, author, subreddit, selftext, url, thumbnailURL, imageURL, score, numComments, createdUTC, isVideo, videoURL, linkFlairText, isSelf, domain, over18, permalink, voteState, isSaved, cachedAt)
                    VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
                    """, arguments: [
                        post.id, post.title, post.author, post.subreddit, post.selftext, post.url,
                        post.thumbnailURL, post.imageURL, post.score, post.numComments, post.createdUTC,
                        post.isVideo, post.videoURL, post.linkFlairText, post.isSelf, post.domain,
                        post.over18, post.permalink, post.voteState.rawValue, post.isSaved, Date()
                    ])
            }
        }
    }

    func clearExpiredCache() {
        let cutoff = Date().addingTimeInterval(-2 * 60 * 60)
        _ = try? dbQueue.write { db in
            try db.execute(sql: "DELETE FROM cached_posts WHERE cachedAt < ?", arguments: [cutoff])
        }
    }
}
