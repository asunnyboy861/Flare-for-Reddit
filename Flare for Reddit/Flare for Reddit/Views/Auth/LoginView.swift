import SwiftUI
import AuthenticationServices

struct LoginView: View {
    @State private var authViewModel = AuthViewModel()
    @State private var isLoading = false
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            Image(systemName: "flame.fill")
                .font(.system(size: 64))
                .foregroundColor(.adaptivePrimary)

            VStack(spacing: 8) {
                Text("Welcome to Flare")
                    .font(.largeTitle.bold())
                    .foregroundColor(.adaptiveText)

                Text("Sign in to unlock the full experience")
                    .font(.body)
                    .foregroundColor(.adaptiveText2)
                    .multilineTextAlignment(.center)
            }

            VStack(spacing: 16) {
                Button(action: startOAuth) {
                    HStack {
                        Image(systemName: "person.circle.fill")
                        Text("Continue with Reddit")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color.adaptivePrimary)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }

                Button(action: { dismiss() }) {
                    Text("Browse without account")
                        .font(.subheadline)
                        .foregroundColor(.adaptiveText2)
                }
            }
            .padding(.horizontal, 32)

            if isLoading {
                ProgressView()
                    .tint(.adaptivePrimary)
            }

            Spacer()
        }
        .background(Color.adaptiveBackground)
        .onOpenURL { url in
            if url.scheme == "flare" && url.host == "auth" {
                Task {
                    await authViewModel.handleCallback(url: url)
                    if authViewModel.isAuthenticated {
                        dismiss()
                    }
                }
            }
        }
    }

    private func startOAuth() {
        isLoading = true
        let authURL = authViewModel.startAuth()
        UIApplication.shared.open(authURL)
    }
}
