import SwiftUI
import NukeUI

struct MediaViewerView: View {
    let imageURL: String
    @Environment(\.dismiss) private var dismiss
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            LazyImage(url: URL(string: imageURL)) { state in
                if let image = state.image {
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .scaleEffect(scale)
                        .gesture(
                            MagnifyGesture()
                                .onChanged { value in
                                    scale = lastScale * value.magnification
                                }
                                .onEnded { _ in
                                    lastScale = scale
                                    if scale < 1.0 {
                                        withAnimation { scale = 1.0; lastScale = 1.0 }
                                    }
                                }
                        )
                        .onTapGesture(count: 2) {
                            withAnimation { scale = scale > 1.0 ? 1.0 : 2.5; lastScale = scale }
                        }
                } else {
                    ProgressView()
                        .tint(.white)
                }
            }
        }
        .overlay(alignment: .topTrailing) {
            Button(action: { dismiss() }) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 30))
                    .foregroundColor(.white.opacity(0.8))
                    .padding()
            }
        }
        .statusBarHidden(true)
    }
}
