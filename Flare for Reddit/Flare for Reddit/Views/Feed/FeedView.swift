import SwiftUI

struct FeedView: View {
    @State private var viewModel = FeedViewModel()
    @State private var selectedPost: Post?
    @State private var showSortPicker = false
    @State private var swipeIndex = 0
    @State private var displayMode: DisplayMode = .list

    enum DisplayMode {
        case list
        case swipe
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.adaptiveBackground.ignoresSafeArea()

                if viewModel.isLoading && viewModel.posts.isEmpty {
                    SkeletonView(count: 6)
                } else if let error = viewModel.error {
                    errorView(error)
                } else if viewModel.posts.isEmpty {
                    emptyView
                } else {
                    contentView
                }
            }
            .navigationTitle(viewModel.currentSubreddit.map { "r/\($0)" } ?? "Flare")
            .navigationBarTitleDisplayMode(.inline)
            .flareNavigation()
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: { showSortPicker.toggle() }) {
                        Image(systemName: viewModel.sortType.iconName)
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: toggleDisplayMode) {
                        Image(systemName: displayMode == .list ? "square.stack.3d.up" : "list.bullet")
                    }
                }
            }
            .sheet(isPresented: $showSortPicker) {
                sortPickerSheet
            }
            .navigationDestination(item: $selectedPost) { post in
                PostDetailView(post: post)
            }
        }
        .task {
            await viewModel.loadInitialFeed()
        }
        .refreshable {
            await viewModel.loadInitialFeed()
        }
    }

    @ViewBuilder
    private var contentView: some View {
        switch displayMode {
        case .list:
            listView
        case .swipe:
            swipeView
        }
    }

    private var listView: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(viewModel.posts) { post in
                    PostCardView(
                        post: post,
                        onUpvote: { Task { await viewModel.vote(post: post, direction: .upvote) } },
                        onDownvote: { Task { await viewModel.vote(post: post, direction: .downvote) } },
                        onTap: { selectedPost = post }
                    )
                    .onAppear {
                        if post.id == viewModel.posts.last?.id {
                            Task { await viewModel.loadMorePosts() }
                        }
                    }
                }

                if viewModel.isLoadingMore {
                    ProgressView()
                        .padding()
                }
            }
            .padding(.horizontal, 16)
            .iPadMaxWidth()
        }
    }

    private var swipeView: some View {
        SwipeNavigationView(
            posts: viewModel.posts,
            currentIndex: $swipeIndex,
            onUpvote: { post in Task { await viewModel.vote(post: post, direction: .upvote) } },
            onDownvote: { post in Task { await viewModel.vote(post: post, direction: .downvote) } },
            onTapPost: { post in selectedPost = post },
            onLoadMore: { Task { await viewModel.loadMorePosts() } }
        )
        .padding(.horizontal, 8)
    }

    private func toggleDisplayMode() {
        withAnimation(.easeInOut(duration: 0.2)) {
            displayMode = displayMode == .list ? .swipe : .list
        }
    }

    private var sortPickerSheet: some View {
        NavigationStack {
            VStack(spacing: 16) {
                SortPickerView(
                    selectedSort: $viewModel.sortType,
                    selectedTime: $viewModel.timeFilter,
                    showTimeFilter: true
                )
                Spacer()
            }
            .padding(.top, 20)
            .navigationTitle("Sort Posts")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { showSortPicker = false }
                }
            }
        }
        .presentationDetents([.medium])
    }

    private func errorView(_ error: RedditError) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "wifi.exclamationmark")
                .font(.system(size: 48))
                .foregroundColor(.adaptiveText2)
            Text(error.localizedDescription)
                .font(.body)
                .foregroundColor(.adaptiveText2)
                .multilineTextAlignment(.center)
            Button("Try Again") {
                Task { await viewModel.loadInitialFeed() }
            }
            .buttonStyle(.borderedProminent)
            .tint(.adaptivePrimary)
        }
        .padding(32)
    }

    private var emptyView: some View {
        VStack(spacing: 16) {
            Image(systemName: "doc.text.magnifyingglass")
                .font(.system(size: 48))
                .foregroundColor(.adaptiveText2)
            Text("No posts found")
                .font(.headline)
                .foregroundColor(.adaptiveText2)
            Button("Refresh") {
                Task { await viewModel.loadInitialFeed() }
            }
            .buttonStyle(.borderedProminent)
            .tint(.adaptivePrimary)
        }
        .padding(32)
    }
}
