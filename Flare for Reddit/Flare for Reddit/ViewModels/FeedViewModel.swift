import SwiftUI

@Observable
final class FeedViewModel {
    var posts: [Post] = []
    var isLoading = false
    var isLoadingMore = false
    var error: RedditError?
    var currentSubreddit: String?
    var sortType: SortType = .hot {
        didSet { if oldValue != sortType { Task { await loadInitialFeed() } }
        }
    }
    var timeFilter: TimeFilter = .day
    var afterCursor: String?
    var hasMore = true
    var showSortPicker = false

    private let api = RedditAPIService.shared
    private let cache = CacheService.shared

    @MainActor
    func loadInitialFeed() async {
        guard !isLoading else { return }
        isLoading = true
        error = nil
        afterCursor = nil
        hasMore = true

        if let cached = cache.getCachedPosts(subreddit: currentSubreddit, sort: sortType), !cached.isEmpty {
            posts = cached
            isLoading = false
        }

        do {
            let result = try await api.getFeed(subreddit: currentSubreddit, sort: sortType, after: nil)
            posts = result.posts
            afterCursor = result.after
            hasMore = result.after != nil
        } catch let err as RedditError {
            error = err
        } catch let err {
            self.error = .networkError(err)
        }

        isLoading = false
    }

    @MainActor
    func loadMorePosts() async {
        guard !isLoadingMore, hasMore, let after = afterCursor else { return }
        isLoadingMore = true

        do {
            let result = try await api.getFeed(subreddit: currentSubreddit, sort: sortType, after: after)
            posts.append(contentsOf: result.posts)
            afterCursor = result.after
            hasMore = result.after != nil
        } catch {
            self.error = .unknown(error.localizedDescription)
        }

        isLoadingMore = false
    }

    @MainActor
    func vote(post: Post, direction: Post.VoteState) async {
        guard AuthService.shared.isAuthenticated else { return }

        let originalState = post.voteState
        if let index = posts.firstIndex(where: { $0.id == post.id }) {
            posts[index].voteState = direction
            switch direction {
            case .upvote: posts[index].score += (originalState == .downvote ? 2 : 1)
            case .downvote: posts[index].score -= (originalState == .upvote ? 2 : 1)
            case .none:
                posts[index].score += (originalState == .upvote ? -1 : 1)
            }
        }

        do {
            try await api.vote(id: post.id, direction: direction)
        } catch {
            if let index = posts.firstIndex(where: { $0.id == post.id }) {
                posts[index].voteState = originalState
            }
        }
    }

    @MainActor
    func toggleSave(post: Post) async {
        guard AuthService.shared.isAuthenticated else { return }

        let newSaveState = !post.isSaved
        if let index = posts.firstIndex(where: { $0.id == post.id }) {
            posts[index].isSaved = newSaveState
        }

        do {
            try await api.save(id: post.id, save: newSaveState)
        } catch {
            if let index = posts.firstIndex(where: { $0.id == post.id }) {
                posts[index].isSaved = !newSaveState
            }
        }
    }

    func setSubreddit(_ name: String?) {
        currentSubreddit = name
        Task { await loadInitialFeed() }
    }
}
