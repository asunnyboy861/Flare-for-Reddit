import SwiftUI

@Observable
final class SearchViewModel {
    var query = ""
    var posts: [Post] = []
    var subreddits: [Subreddit] = []
    var isLoading = false
    var error: RedditError?
    var recentSearches: [String] = []
    var afterCursor: String?
    var hasMore = true

    private let api = RedditAPIService.shared

    init() {
        loadRecentSearches()
    }

    @MainActor
    func search() async {
        guard !query.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        isLoading = true
        error = nil
        afterCursor = nil
        hasMore = true

        saveRecentSearch(query)

        do {
            let result = try await api.search(query: query)
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
    func loadMore() async {
        guard !isLoading, hasMore, let after = afterCursor else { return }
        isLoading = true

        do {
            let result = try await api.search(query: query, after: after)
            posts.append(contentsOf: result.posts)
            afterCursor = result.after
            hasMore = result.after != nil
        } catch let err {
            self.error = .networkError(err)
        }

        isLoading = false
    }

    private func loadRecentSearches() {
        recentSearches = UserDefaults.standard.stringArray(forKey: "recent_searches") ?? []
    }

    private func saveRecentSearch(_ query: String) {
        var searches = recentSearches
        searches.removeAll { $0 == query }
        searches.insert(query, at: 0)
        if searches.count > 10 { searches = Array(searches.prefix(10)) }
        recentSearches = searches
        UserDefaults.standard.set(searches, forKey: "recent_searches")
    }

    func clearRecentSearches() {
        recentSearches = []
        UserDefaults.standard.removeObject(forKey: "recent_searches")
    }
}
