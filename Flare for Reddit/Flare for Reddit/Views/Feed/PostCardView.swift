import SwiftUI
import NukeUI

struct PostCardView: View {
    let post: Post
    let onUpvote: () -> Void
    let onDownvote: () -> Void
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 8) {
                headerRow
                titleText
                if post.isSelf && !post.selftext.isEmpty {
                    bodyPreview
                }
                if let imageURL = post.imageURL, !post.isVideo {
                    postImage(url: imageURL)
                }
                footerRow
            }
            .padding(16)
            .background(Color.adaptiveSurface)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .shadow(color: .black.opacity(0.04), radius: 3, x: 0, y: 1)
        }
        .buttonStyle(.plain)
    }

    private var headerRow: some View {
        HStack(spacing: 6) {
            Text("r/\(post.subreddit)")
                .font(.subheadline.weight(.semibold))
                .foregroundColor(.adaptivePrimary)

            Text("·")
                .foregroundColor(.adaptiveText2)

            Text(post.author)
                .font(.subheadline)
                .foregroundColor(.adaptiveText2)

            Text("·")
                .foregroundColor(.adaptiveText2)

            Text(post.timeAgo)
                .font(.caption)
                .foregroundColor(.adaptiveText2)

            Spacer()

            if let flair = post.linkFlairText {
                Text(flair)
                    .font(.caption2.weight(.medium))
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.adaptivePrimary.opacity(0.12))
                    .foregroundColor(.adaptivePrimary)
                    .clipShape(RoundedRectangle(cornerRadius: 4))
            }
        }
    }

    private var titleText: some View {
        Text(post.title)
            .font(.title3.weight(.semibold))
            .foregroundColor(.adaptiveText)
            .lineLimit(3)
            .multilineTextAlignment(.leading)
    }

    private var bodyPreview: some View {
        Text(post.selftext)
            .font(.subheadline)
            .foregroundColor(.adaptiveText2)
            .lineLimit(2)
            .multilineTextAlignment(.leading)
    }

    private func postImage(url: String) -> some View {
        LazyImage(url: URL(string: url)) { state in
            if let image = state.image {
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(maxHeight: 280)
                    .clipped()
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            } else {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.adaptiveText2.opacity(0.1))
                    .frame(height: 180)
                    .shimmer(active: true)
            }
        }
    }

    private var footerRow: some View {
        HStack(spacing: 16) {
            VoteButton(
                voteState: post.voteState,
                score: post.score,
                onUpvote: onUpvote,
                onDownvote: onDownvote
            )

            HStack(spacing: 4) {
                Image(systemName: "bubble.right")
                    .font(.system(size: 14))
                Text("\(post.numComments)")
                    .font(.subheadline)
            }
            .foregroundColor(.adaptiveText2)

            Spacer()

            if post.isSaved {
                Image(systemName: "bookmark.fill")
                    .font(.system(size: 14))
                    .foregroundColor(.adaptivePrimary)
            }

            ShareLink(item: "https://reddit.com\(post.permalink)") {
                Image(systemName: "square.and.arrow.up")
                    .font(.system(size: 14))
                    .foregroundColor(.adaptiveText2)
            }
        }
    }
}
