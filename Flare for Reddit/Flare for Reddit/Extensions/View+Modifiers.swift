import SwiftUI

extension View {
    func flareCard() -> some View {
        self
            .background(Color.adaptiveSurface)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }

    func flareNavigation() -> some View {
        self.toolbarBackground(.ultraThinMaterial, for: .navigationBar)
    }

    func flareTabBar() -> some View {
        self.toolbarBackground(.ultraThinMaterial, for: .tabBar)
    }

    func shimmer(active: Bool) -> some View {
        self.overlay {
            if active {
                SkeletonShimmerView()
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
        }
    }

    func hapticFeedback(style: UIImpactFeedbackGenerator.FeedbackStyle = .light) {
        UIImpactFeedbackGenerator(style: style).impactOccurred()
    }

    func iPadMaxWidth() -> some View {
        self.frame(maxWidth: 720).frame(maxWidth: .infinity)
    }
}

struct SkeletonShimmerView: View {
    @State private var isAnimating = false

    var body: some View {
        LinearGradient(
            colors: [
                Color.adaptiveSurface,
                Color.adaptiveText2.opacity(0.15),
                Color.adaptiveSurface
            ],
            startPoint: .leading,
            endPoint: .trailing
        )
        .offset(x: isAnimating ? 300 : -300)
        .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: false), value: isAnimating)
        .onAppear { isAnimating = true }
    }
}
