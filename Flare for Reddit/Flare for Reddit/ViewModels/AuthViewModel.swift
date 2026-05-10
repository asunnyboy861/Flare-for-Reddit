import SwiftUI

@Observable
final class AuthViewModel {
    var isAuthenticated = false
    var currentUser: User?
    var username: String?
    var isLoading = false
    var error: RedditError?

    private let authService = AuthService.shared

    init() {
        isAuthenticated = authService.isAuthenticated
        username = UserDefaults.standard.string(forKey: "current_username")
    }

    @MainActor
    func startAuth() -> URL {
        authService.buildAuthURL()
    }

    @MainActor
    func handleCallback(url: URL) async {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let code = components.queryItems?.first(where: { $0.name == "code" })?.value else {
            error = .invalidResponse
            return
        }

        isLoading = true
        do {
            let token = try await authService.exchangeCodeForToken(code: code)
            isAuthenticated = true
            UserDefaults.standard.set(token.accessToken, forKey: "temp_access_token")
        } catch let err as RedditError {
            error = err
        } catch let err {
            self.error = .networkError(err)
        }
        isLoading = false
    }

    @MainActor
    func logout() {
        authService.logout()
        isAuthenticated = false
        currentUser = nil
        username = nil
    }
}
