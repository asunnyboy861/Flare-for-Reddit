import SwiftUI

@Observable
final class CommentViewModel {
    var comments: [Comment] = []
    var collapsedIds: Set<String> = []

    func toggleCollapse(_ commentId: String) {
        if collapsedIds.contains(commentId) {
            collapsedIds.remove(commentId)
        } else {
            collapsedIds.insert(commentId)
        }
    }

    func isCollapsed(_ commentId: String) -> Bool {
        collapsedIds.contains(commentId)
    }

    func visibleComments(from comments: [Comment]) -> [Comment] {
        var result: [Comment] = []
        for comment in comments {
            result.append(comment)
            if !isCollapsed(comment.id), let replies = comment.replies {
                result.append(contentsOf: visibleComments(from: replies))
            }
        }
        return result
    }
}
