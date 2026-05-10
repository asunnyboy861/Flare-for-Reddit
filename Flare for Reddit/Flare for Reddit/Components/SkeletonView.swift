import SwiftUI

struct SkeletonView: View {
    let count: Int

    init(count: Int = 5) {
        self.count = count
    }

    var body: some View {
        VStack(spacing: 16) {
            ForEach(0..<count, id: \.self) { _ in
                skeletonRow
            }
        }
        .padding(.horizontal, 16)
    }

    private var skeletonRow: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Circle()
                    .fill(Color.adaptiveText2.opacity(0.2))
                    .frame(width: 24, height: 24)
                    .shimmer(active: true)

                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.adaptiveText2.opacity(0.2))
                    .frame(width: 80, height: 14)
                    .shimmer(active: true)

                Spacer()

                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.adaptiveText2.opacity(0.2))
                    .frame(width: 40, height: 14)
                    .shimmer(active: true)
            }

            RoundedRectangle(cornerRadius: 4)
                .fill(Color.adaptiveText2.opacity(0.2))
                .frame(height: 18)
                .shimmer(active: true)

            RoundedRectangle(cornerRadius: 4)
                .fill(Color.adaptiveText2.opacity(0.2))
                .frame(height: 14)
                .padding(.trailing, 60)
                .shimmer(active: true)

            HStack(spacing: 16) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.adaptiveText2.opacity(0.2))
                    .frame(width: 50, height: 12)
                    .shimmer(active: true)

                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.adaptiveText2.opacity(0.2))
                    .frame(width: 50, height: 12)
                    .shimmer(active: true)
            }
        }
        .padding(16)
        .background(Color.adaptiveSurface)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
