import Foundation

struct AuthToken: Codable, Sendable {
    let accessToken: String
    let tokenType: String
    let expiresIn: Int
    let scope: String
    let refreshToken: String?

    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case tokenType = "token_type"
        case expiresIn = "expires_in"
        case scope
        case refreshToken = "refresh_token"
    }

    var expirationDate: Date {
        Date().addingTimeInterval(TimeInterval(expiresIn))
    }

    var isExpired: Bool {
        Date() >= expirationDate
    }
}
