import SwiftUI

struct SwipeNavigationView: View {
    let posts: [Post]
    @Binding var currentIndex: Int
    let onUpvote: (Post) -> Void
    let onDownvote: (Post) -> Void
    let onTapPost: (Post) -> Void
    let onLoadMore: () -> Void

    @State private var offset: CGFloat = 0
    @State private var showHint = false

    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width

            ZStack {
                ForEach(Array(posts.enumerated()), id: \.element.id) { index, post in
                    PostCardView(
                        post: post,
                        onUpvote: { onUpvote(post) },
                        onDownvote: { onDownvote(post) },
                        onTap: { onTapPost(post) }
                    )
                    .frame(width: width - 32, height: geometry.size.height - 16)
                    .offset(x: CGFloat(index - currentIndex) * (width - 16) + offset)
                    .opacity(index == currentIndex ? 1.0 : 0.6)
                    .scaleEffect(index == currentIndex ? 1.0 : 0.92)
                }
            }
            .gesture(
                DragGesture(minimumDistance: 20)
                    .onChanged { value in
                        offset = value.translation.width
                    }
                    .onEnded { value in
                        let threshold: CGFloat = width * 0.25
                        let velocity = value.predictedEndTranslation.width - value.translation.width

                        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                            if value.translation.width < -threshold || velocity < -50 {
                                if currentIndex < posts.count - 1 {
                                    currentIndex += 1
                                    offset = 0
                                    checkPreload()
                                } else {
                                    offset = 0
                                }
                            } else if value.translation.width > threshold || velocity > 50 {
                                if currentIndex > 0 {
                                    currentIndex -= 1
                                    offset = 0
                                } else {
                                    offset = 0
                                }
                            } else {
                                offset = 0
                            }
                        }
                    }
            )
        }
        .overlay(alignment: .bottom) {
            if showHint {
                Text("Swipe for next post")
                    .font(.caption)
                    .foregroundColor(.adaptiveText2)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(.ultraThinMaterial)
                    .clipShape(Capsule())
                    .transition(.opacity)
                    .padding(.bottom, 8)
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                withAnimation(.easeInOut(duration: 0.3)) {
                    showHint = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        showHint = false
                    }
                }
            }
        }
    }

    private func checkPreload() {
        if currentIndex >= posts.count - 5 {
            onLoadMore()
        }
    }
}
