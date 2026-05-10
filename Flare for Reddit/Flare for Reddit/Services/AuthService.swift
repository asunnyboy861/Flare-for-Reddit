import Foundation
import Alamofire

final class AuthService: @unchecked Sendable {
    static let shared = AuthService()

    private let keychain = KeychainManager.shared
    private var currentToken: AuthToken?

    var isAuthenticated: Bool {
        currentToken != nil && !(currentToken?.isExpired ?? true)
    }

    var accessToken: String? {
        currentToken?.accessToken
    }

    private init() {
        currentToken = keychain.loadAuthToken()
    }

    func buildAuthURL() -> URL {
        var components = URLComponents(string: "https://www.reddit.com/api/v1/authorize")!
        let clientId = RedditConfig.clientId
        let redirectURI = RedditConfig.redirectURI
        let state = UUID().uuidString
        let scope = "identity read vote submit save subscribe history"

        components.queryItems = [
            URLQueryItem(name: "client_id", value: clientId),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "state", value: state),
            URLQueryItem(name: "redirect_uri", value: redirectURI),
            URLQueryItem(name: "duration", value: "permanent"),
            URLQueryItem(name: "scope", value: scope)
        ]
        return components.url!
    }

    func exchangeCodeForToken(code: String) async throws -> AuthToken {
        let response = try await AF.request(
            "https://www.reddit.com/api/v1/access_token",
            method: .post,
            parameters: [
                "grant_type": "authorization_code",
                "code": code,
                "redirect_uri": RedditConfig.redirectURI
            ],
            headers: HTTPHeaders([
                "Authorization": "Basic \(RedditConfig.clientCredentials)",
                "Content-Type": "application/x-www-form-urlencoded"
            ])
        ).serializingDecodable(AuthToken.self).value

        currentToken = response
        keychain.saveAuthToken(response)
        return response
    }

    func refreshToken() async throws -> AuthToken {
        guard let refreshToken = keychain.load(key: "refresh_token") else {
            throw RedditError.tokenExpired
        }

        let response = try await AF.request(
            "https://www.reddit.com/api/v1/access_token",
            method: .post,
            parameters: [
                "grant_type": "refresh_token",
                "refresh_token": refreshToken
            ],
            headers: HTTPHeaders([
                "Authorization": "Basic \(RedditConfig.clientCredentials)",
                "Content-Type": "application/x-www-form-urlencoded"
            ])
        ).serializingDecodable(AuthToken.self).value

        currentToken = response
        keychain.saveAuthToken(response)
        return response
    }

    func logout() {
        currentToken = nil
        keychain.clearAll()
        UserDefaults.standard.removeObject(forKey: "current_username")
    }

    func getValidToken() async throws -> String {
        if let token = currentToken, !token.isExpired {
            return token.accessToken
        }
        let newToken = try await refreshToken()
        return newToken.accessToken
    }
}

enum RedditConfig {
    static let clientId = "REDDIT_CLIENT_ID"
    static let clientSecret = "REDDIT_CLIENT_SECRET"
    static let redirectURI = "flare://auth"
    static let clientCredentials: String = {
        let credentials = "\(clientId):\(clientSecret)"
        return Data(credentials.utf8).base64EncodedString()
    }()
    static let baseURL = "https://oauth.reddit.com"
    static let publicBaseURL = "https://www.reddit.com"
}
