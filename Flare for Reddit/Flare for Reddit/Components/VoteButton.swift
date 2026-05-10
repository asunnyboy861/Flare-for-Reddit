import SwiftUI

struct VoteButton: View {
    let voteState: Post.VoteState
    let score: Int
    let onUpvote: () -> Void
    let onDownvote: () -> Void

    var body: some View {
        HStack(spacing: 4) {
            Button(action: onUpvote) {
                Image(systemName: voteState == .upvote ? "arrow.up.circle.fill" : "arrow.up.circle")
                    .font(.system(size: 20))
                    .foregroundColor(voteState == .upvote ? .adaptiveUpvote : .adaptiveText2)
            }

            Text(displayScore)
                .font(.subheadline.bold())
                .foregroundColor(scoreColor)
                .monospacedDigit()

            Button(action: onDownvote) {
                Image(systemName: voteState == .downvote ? "arrow.down.circle.fill" : "arrow.down.circle")
                    .font(.system(size: 20))
                    .foregroundColor(voteState == .downvote ? .adaptiveDownvote : .adaptiveText2)
            }
        }
    }

    private var displayScore: String {
        let adjustedScore: Int
        switch voteState {
        case .upvote: adjustedScore = score
        case .downvote: adjustedScore = score
        case .none: adjustedScore = score
        }
        if adjustedScore >= 1000 {
            return String(format: "%.1fk", Double(adjustedScore) / 1000.0)
        }
        return "\(adjustedScore)"
    }

    private var scoreColor: Color {
        switch voteState {
        case .upvote: return .adaptiveUpvote
        case .downvote: return .adaptiveDownvote
        case .none: return .adaptiveText2
        }
    }
}
