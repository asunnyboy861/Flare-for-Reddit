import SwiftUI

@Observable
final class PostViewModel {
    var post: Post?
    var comments: [Comment] = []
    var isLoading = false
    var error: RedditError?
    var isCollapsed: Set<String> = []

    private let api = RedditAPIService.shared

    @MainActor
    func loadPost(subreddit: String, postId: String) async {
        isLoading = true
        error = nil

        do {
            let (post, comments) = try await api.getPostComments(subreddit: subreddit, postId: postId)
            self.post = post
            self.comments = comments
        } catch let err as RedditError {
            error = err
        } catch let err {
            self.error = .networkError(err)
        }

        isLoading = false
    }

    @MainActor
    func vote(post: Post, direction: Post.VoteState) async {
        guard AuthService.shared.isAuthenticated else { return }

        let originalState = self.post?.voteState ?? .none
        self.post?.voteState = direction
        switch direction {
        case .upvote: self.post?.score += (originalState == .downvote ? 2 : 1)
        case .downvote: self.post?.score -= (originalState == .upvote ? 2 : 1)
        case .none: self.post?.score += (originalState == .upvote ? -1 : 1)
        }

        do {
            try await api.vote(id: post.id, direction: direction)
        } catch {
            self.post?.voteState = originalState
        }
    }

    @MainActor
    func voteComment(comment: Comment, direction: Post.VoteState) async {
        guard AuthService.shared.isAuthenticated else { return }
        try? await api.vote(id: comment.id, direction: direction)
    }

    func toggleCollapse(commentId: String) {
        if isCollapsed.contains(commentId) {
            isCollapsed.remove(commentId)
        } else {
            isCollapsed.insert(commentId)
        }
    }
}
