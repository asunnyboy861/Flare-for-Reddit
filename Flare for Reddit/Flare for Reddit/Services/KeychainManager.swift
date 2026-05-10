import Foundation
@preconcurrency import KeychainAccess

final class KeychainManager: @unchecked Sendable {
    static let shared = KeychainManager()

    private let keychain: Keychain

    private init() {
        keychain = Keychain(service: "com.zzoutuo.Flare-for-Reddit")
            .synchronizable(false)
    }

    func save(token: String, key: String) {
        try? keychain.set(token, key: key)
    }

    func load(key: String) -> String? {
        try? keychain.get(key)
    }

    func delete(key: String) {
        try? keychain.remove(key)
    }

    func saveAuthToken(_ token: AuthToken) {
        save(token: token.accessToken, key: "access_token")
        if let refresh = token.refreshToken {
            save(token: refresh, key: "refresh_token")
        }
        save(token: "\(token.expiresIn)", key: "token_expires_in")
        save(token: token.scope, key: "token_scope")
        if let data = try? JSONEncoder().encode(token) {
            save(token: data.base64EncodedString(), key: "auth_token_full")
        }
    }

    func loadAuthToken() -> AuthToken? {
        guard let dataString = load(key: "auth_token_full"),
              let data = Data(base64Encoded: dataString),
              let token = try? JSONDecoder().decode(AuthToken.self, from: data) else {
            return nil
        }
        return token
    }

    func clearAll() {
        try? keychain.removeAll()
    }
}
