import SwiftUI

struct CommentCellView: View {
    let comment: Comment
    let isCollapsed: Bool
    let onToggleCollapse: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            headerRow
            if !isCollapsed {
                MarkdownRenderer(content: comment.body)
                    .padding(.top, 2)
                footerRow
            }
        }
        .padding(.vertical, 8)
        .contentShape(Rectangle())
        .onTapGesture { onToggleCollapse() }
    }

    private var headerRow: some View {
        HStack(spacing: 6) {
            if isCollapsed {
                Image(systemName: "chevron.right")
                    .font(.caption2)
                    .foregroundColor(.adaptiveText2)
            }

            Text(comment.author)
                .font(.subheadline.weight(.semibold))
                .foregroundColor(comment.isSubmitter ? .adaptivePrimary : .adaptiveText)

            if comment.isSubmitter {
                Text("OP")
                    .font(.caption2.weight(.bold))
                    .padding(.horizontal, 4)
                    .padding(.vertical, 1)
                    .background(Color.adaptivePrimary.opacity(0.15))
                    .foregroundColor(.adaptivePrimary)
                    .clipShape(RoundedRectangle(cornerRadius: 3))
            }

            Text(comment.timeAgo)
                .font(.caption)
                .foregroundColor(.adaptiveText2)

            Spacer()

            Text(comment.displayScore)
                .font(.caption.weight(.medium))
                .foregroundColor(.adaptiveText2)
        }
    }

    private var footerRow: some View {
        HStack(spacing: 16) {
            Button(action: {}) {
                HStack(spacing: 2) {
                    Image(systemName: "arrow.up")
                        .font(.system(size: 12))
                    Text("\(comment.score)")
                        .font(.caption)
                }
                .foregroundColor(.adaptiveText2)
            }

            if AuthService.shared.isAuthenticated {
                Button(action: {}) {
                    HStack(spacing: 2) {
                        Image(systemName: "arrow.down")
                            .font(.system(size: 12))
                    }
                    .foregroundColor(.adaptiveText2)
                }

                Button(action: {}) {
                    HStack(spacing: 2) {
                        Image(systemName: "arrowshape.turn.up.left")
                            .font(.system(size: 12))
                        Text("Reply")
                            .font(.caption)
                    }
                    .foregroundColor(.adaptiveText2)
                }
            }
        }
        .padding(.top, 2)
    }
}
