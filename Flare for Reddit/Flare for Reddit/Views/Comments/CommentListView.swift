import SwiftUI

struct CommentListView: View {
    let comments: [Comment]
    @State private var viewModel = CommentViewModel()

    var body: some View {
        LazyVStack(alignment: .leading, spacing: 0) {
            ForEach(comments) { comment in
                CommentCellView(
                    comment: comment,
                    isCollapsed: viewModel.isCollapsed(comment.id),
                    onToggleCollapse: { viewModel.toggleCollapse(comment.id) }
                )

                if !viewModel.isCollapsed(comment.id), let replies = comment.replies, !replies.isEmpty {
                    CommentListView(comments: replies)
                        .padding(.leading, 20)
                        .overlay(alignment: .leading) {
                            Rectangle()
                                .fill(Color.adaptiveText2.opacity(0.2))
                                .frame(width: 2)
                                .padding(.leading, 8)
                        }
                }
            }
        }
    }
}
