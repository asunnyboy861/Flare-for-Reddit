import SwiftUI
import StoreKit

struct PaywallView: View {
    @State private var purchaseManager = PurchaseManager.shared
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                Color.adaptiveBackground.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        headerSection
                        featuresSection
                        pricingSection
                        restoreButton
                        termsText
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 32)
                    .iPadMaxWidth()
                }
            }
            .navigationTitle("Flare Pro")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Close") { dismiss() }
                }
            }
        }
        .task {
            await purchaseManager.loadProducts()
        }
    }

    private var headerSection: some View {
        VStack(spacing: 12) {
            Image(systemName: "crown.fill")
                .font(.system(size: 48))
                .foregroundColor(.yellow)

            Text("Unlock Flare Pro")
                .font(.title.bold())
                .foregroundColor(.adaptiveText)

            Text("Get the full Reddit experience")
                .font(.body)
                .foregroundColor(.adaptiveText2)
        }
        .padding(.top, 20)
    }

    private var featuresSection: some View {
        VStack(spacing: 12) {
            featureRow(icon: "infinity", title: "Unlimited Browsing", desc: "No daily limits")
            featureRow(icon: "bubble.left.and.bubble.right", title: "Comment & Reply", desc: "Full interaction")
            featureRow(icon: "square.and.pencil", title: "Post Submission", desc: "Share your thoughts")
            featureRow(icon: "person.2", title: "Multi-Account", desc: "Switch accounts easily")
            featureRow(icon: "paintbrush", title: "Custom Themes", desc: "Personalize your experience")
        }
        .padding(16)
        .background(Color.adaptiveSurface)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private func featureRow(icon: String, title: String, desc: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(.adaptivePrimary)
                .frame(width: 28)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(.adaptiveText)
                Text(desc)
                    .font(.caption)
                    .foregroundColor(.adaptiveText2)
            }

            Spacer()

            Image(systemName: "checkmark")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.adaptiveSuccess)
        }
    }

    private var pricingSection: some View {
        VStack(spacing: 12) {
            if purchaseManager.products.isEmpty {
                ProgressView()
                    .padding()
            } else {
                ForEach(purchaseManager.products, id: \.id) { product in
                    productCard(product)
                }
            }
        }
    }

    private func productCard(_ product: Product) -> some View {
        Button(action: { Task { _ = await purchaseManager.purchase(product) } }) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(product.displayName)
                        .font(.headline)
                        .foregroundColor(.adaptiveText)

                    if product.id.contains("yearly") {
                        Text("Save 58%")
                            .font(.caption2.weight(.bold))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.adaptiveSuccess.opacity(0.15))
                            .foregroundColor(.adaptiveSuccess)
                            .clipShape(Capsule())
                    }

                    if product.id.contains("lifetime") {
                        Text("One-time purchase")
                            .font(.caption2.weight(.bold))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.adaptivePrimary.opacity(0.15))
                            .foregroundColor(.adaptivePrimary)
                            .clipShape(Capsule())
                    }
                }

                Spacer()

                Text(product.displayPrice)
                    .font(.title3.bold())
                    .foregroundColor(.adaptivePrimary)

                if product.subscription != nil {
                    Text("/ " + (product.id.contains("monthly") ? "mo" : "yr"))
                        .font(.caption)
                        .foregroundColor(.adaptiveText2)
                }
            }
            .padding(16)
            .background(Color.adaptiveSurface)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(product.id.contains("yearly") ? Color.adaptivePrimary : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
    }

    private var restoreButton: some View {
        Button(action: { Task { await purchaseManager.restorePurchases() } }) {
            Text("Restore Purchases")
                .font(.subheadline)
                .foregroundColor(.adaptivePrimary)
        }
    }

    private var termsText: some View {
        VStack(spacing: 4) {
            Text("Payment will be charged to your Apple ID account at confirmation of purchase.")
                .font(.caption2)
                .foregroundColor(.adaptiveText2)
                .multilineTextAlignment(.center)
            Text("Subscription automatically renews unless it is canceled at least 24 hours before the end of the current period.")
                .font(.caption2)
                .foregroundColor(.adaptiveText2)
                .multilineTextAlignment(.center)
        }
    }
}
