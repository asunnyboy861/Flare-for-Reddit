import SwiftUI
import SafariServices

struct SettingsView: View {
    @State private var authViewModel = AuthViewModel()
    @State private var purchaseManager = PurchaseManager.shared
    @State private var showPaywall = false
    @State private var selectedAppearance: AppearanceMode = .system

    enum AppearanceMode: String, CaseIterable {
        case system = "System"
        case light = "Light"
        case dark = "Dark"
    }

    var body: some View {
        NavigationStack {
            Form {
                accountSection
                proSection
                appearanceSection
                aboutSection
            }
            .scrollContentBackground(.hidden)
            .background(Color.adaptiveBackground)
            .navigationTitle("Settings")
            .flareNavigation()
            .sheet(isPresented: $showPaywall) {
                PaywallView()
            }
        }
    }

    private var accountSection: some View {
        Section {
            if authViewModel.isAuthenticated {
                HStack(spacing: 12) {
                    Image(systemName: "person.circle.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.adaptivePrimary)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(authViewModel.username ?? "Reddit User")
                            .font(.headline)
                        Text("Authenticated")
                            .font(.caption)
                            .foregroundColor(.adaptiveSuccess)
                    }

                    Spacer()
                }

                Button(role: .destructive, action: { authViewModel.logout() }) {
                    Label("Sign Out", systemImage: "rectangle.portrait.and.arrow.right")
                }
            } else {
                NavigationLink(destination: LoginView()) {
                    Label("Sign in with Reddit", systemImage: "person.badge.plus")
                }
            }
        } header: {
            Text("Account")
        }
    }

    private var proSection: some View {
        Section {
            if purchaseManager.isProUser {
                HStack {
                    Image(systemName: "crown.fill")
                        .foregroundColor(.yellow)
                    Text("Flare Pro Active")
                        .foregroundColor(.adaptiveSuccess)
                    Spacer()
                }
            } else {
                Button(action: { showPaywall = true }) {
                    HStack {
                        Image(systemName: "crown")
                            .foregroundColor(.yellow)
                        Text("Upgrade to Flare Pro")
                            .foregroundColor(.adaptivePrimary)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundColor(.adaptiveText2)
                    }
                }
            }

            Button(action: { Task { await purchaseManager.restorePurchases() } }) {
                Label("Restore Purchases", systemImage: "arrow.clockwise")
            }
        } header: {
            Text("Flare Pro")
        }
    }

    private var appearanceSection: some View {
        Section {
            Picker("Appearance", selection: $selectedAppearance) {
                ForEach(AppearanceMode.allCases, id: \.self) { mode in
                    Text(mode.rawValue).tag(mode)
                }
            }

            Toggle("Compact Mode", isOn: .constant(false))
        } header: {
            Text("Appearance")
        }
    }

    private var aboutSection: some View {
        Section {
            NavigationLink(destination: WebView(url: URL(string: "https://asunnyboy861.github.io/Flare-for-Reddit/support.html")!)) {
                Label("Support", systemImage: "questionmark.circle")
            }

            NavigationLink(destination: WebView(url: URL(string: "https://asunnyboy861.github.io/Flare-for-Reddit/privacy.html")!)) {
                Label("Privacy Policy", systemImage: "hand.raised")
            }

            NavigationLink(destination: WebView(url: URL(string: "https://asunnyboy861.github.io/Flare-for-Reddit/terms.html")!)) {
                Label("Terms of Use", systemImage: "doc.text")
            }

            NavigationLink(destination: ContactSupportView()) {
                Label("Contact Support", systemImage: "envelope")
            }

            HStack {
                Text("Version")
                Spacer()
                Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0")
                    .foregroundColor(.adaptiveText2)
            }
        } header: {
            Text("About")
        }
    }
}

struct WebView: UIViewControllerRepresentable {
    let url: URL

    func makeUIViewController(context: Context) -> SFSafariViewController {
        SFSafariViewController(url: url)
    }

    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {}
}
