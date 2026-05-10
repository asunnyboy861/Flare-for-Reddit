import SwiftUI

struct SearchView: View {
    @State private var viewModel = SearchViewModel()
    @State private var selectedPost: Post?
    @FocusState private var isSearchFocused: Bool

    var body: some View {
        NavigationStack {
            ZStack {
                Color.adaptiveBackground.ignoresSafeArea()

                VStack(spacing: 0) {
                    searchField
                    contentArea
                }
            }
            .navigationTitle("Search")
            .navigationBarTitleDisplayMode(.inline)
            .flareNavigation()
            .navigationDestination(item: $selectedPost) { post in
                PostDetailView(post: post)
            }
        }
    }

    private var searchField: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.adaptiveText2)

            TextField("Search Reddit", text: $viewModel.query)
                .textFieldStyle(.plain)
                .font(.body)
                .focused($isSearchFocused)
                .submitLabel(.search)
                .onSubmit {
                    Task { await viewModel.search() }
                }

            if !viewModel.query.isEmpty {
                Button(action: { viewModel.query = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.adaptiveText2)
                }
            }
        }
        .padding(10)
        .background(Color.adaptiveSurface)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .padding(.horizontal, 16)
        .padding(.top, 8)
    }

    @ViewBuilder
    private var contentArea: some View {
        if viewModel.isLoading {
            Spacer()
            ProgressView()
            Spacer()
        } else if viewModel.posts.isEmpty && viewModel.query.isEmpty {
            recentSearchesView
        } else if viewModel.posts.isEmpty {
            VStack(spacing: 16) {
                Spacer()
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 48))
                    .foregroundColor(.adaptiveText2)
                Text("No results found")
                    .font(.headline)
                    .foregroundColor(.adaptiveText2)
                Spacer()
            }
        } else {
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(viewModel.posts) { post in
                        PostCardView(
                            post: post,
                            onUpvote: {},
                            onDownvote: {},
                            onTap: { selectedPost = post }
                        )
                        .onAppear {
                            if post.id == viewModel.posts.last?.id {
                                Task { await viewModel.loadMore() }
                            }
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
                .iPadMaxWidth()
            }
        }
    }

    private var recentSearchesView: some View {
        VStack(alignment: .leading, spacing: 12) {
            if !viewModel.recentSearches.isEmpty {
                HStack {
                    Text("Recent Searches")
                        .font(.headline)
                        .foregroundColor(.adaptiveText)
                    Spacer()
                    Button("Clear") {
                        viewModel.clearRecentSearches()
                    }
                    .font(.subheadline)
                    .foregroundColor(.adaptivePrimary)
                }
                .padding(.horizontal, 16)

                ForEach(viewModel.recentSearches, id: \.self) { search in
                    Button(action: {
                        viewModel.query = search
                        Task { await viewModel.search() }
                    }) {
                        HStack {
                            Image(systemName: "clock")
                                .foregroundColor(.adaptiveText2)
                            Text(search)
                                .foregroundColor(.adaptiveText)
                            Spacer()
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                    }
                }
            }

            Spacer()
        }
        .padding(.top, 16)
    }
}
