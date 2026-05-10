import SwiftUI
import NukeUI
import MarkdownUI

struct PostDetailView: View {
    let post: Post
    @State private var viewModel = PostViewModel()
    @State private var showMediaViewer = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                postHeader
                postContent
                Divider().padding(.vertical, 12)
                commentsSection
            }
            .padding(.horizontal, 16)
            .iPadMaxWidth()
        }
        .background(Color.adaptiveBackground)
        .navigationTitle("r/\(post.subreddit)")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await viewModel.loadPost(subreddit: post.subreddit, postId: post.id)
        }
        .fullScreenCover(isPresented: $showMediaViewer) {
            if let imageURL = post.imageURL ?? post.thumbnailURL {
                MediaViewerView(imageURL: imageURL)
            }
        }
    }

    private var postHeader: some View {
        VStack(alignment: .leading, spacing: 8) {
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
            }

            Text(post.title)
                .font(.title2.weight(.bold))
                .foregroundColor(.adaptiveText)

            HStack(spacing: 16) {
                VoteButton(
                    voteState: viewModel.post?.voteState ?? post.voteState,
                    score: viewModel.post?.score ?? post.score,
                    onUpvote: { Task { await viewModel.vote(post: post, direction: .upvote) } },
                    onDownvote: { Task { await viewModel.vote(post: post, direction: .downvote) } }
                )

                HStack(spacing: 4) {
                    Image(systemName: "bubble.right")
                    Text("\(post.numComments)")
                }
                .font(.subheadline)
                .foregroundColor(.adaptiveText2)

                Spacer()

                ShareLink(item: "https://reddit.com\(post.permalink)") {
                    Image(systemName: "square.and.arrow.up")
                        .foregroundColor(.adaptiveText2)
                }
            }
        }
        .padding(.top, 12)
    }

    @ViewBuilder
    private var postContent: some View {
        if post.isSelf && !post.selftext.isEmpty {
            MarkdownRenderer(content: post.selftext)
                .padding(.top, 12)
        }

        if let imageURL = post.imageURL, !post.isVideo {
            Button(action: { showMediaViewer = true }) {
                LazyImage(url: URL(string: imageURL)) { state in
                    if let image = state.image {
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    } else {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.adaptiveText2.opacity(0.1))
                            .frame(height: 200)
                            .shimmer(active: true)
                    }
                }
            }
            .padding(.top, 12)
        }

        if post.isVideo, let videoURL = post.videoURL {
            VideoPlayerView(url: videoURL)
                .frame(height: 220)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding(.top, 12)
        }
    }

    private var commentsSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Comments")
                .font(.headline)
                .foregroundColor(.adaptiveText)
                .padding(.bottom, 12)

            if viewModel.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity)
                    .padding()
            } else if viewModel.comments.isEmpty {
                Text("No comments yet")
                    .font(.subheadline)
                    .foregroundColor(.adaptiveText2)
                    .padding()
            } else {
                CommentListView(comments: viewModel.comments)
            }
        }
    }
}

struct VideoPlayerView: UIViewRepresentable {
    let url: String

    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        view.backgroundColor = .black
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {}
}
