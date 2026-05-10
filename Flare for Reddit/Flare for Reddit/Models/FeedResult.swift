import Foundation

struct FeedResult: Sendable {
    let posts: [Post]
    let after: String?
    let before: String?

    static let empty = FeedResult(posts: [], after: nil, before: nil)
}

enum SortType: String, CaseIterable, Sendable {
    case hot = "hot"
    case new = "new"
    case rising = "rising"
    case top = "top"
    case controversial = "controversial"

    var displayName: String {
        switch self {
        case .hot: return "Hot"
        case .new: return "New"
        case .rising: return "Rising"
        case .top: return "Top"
        case .controversial: return "Controversial"
        }
    }

    var iconName: String {
        switch self {
        case .hot: return "flame.fill"
        case .new: return "clock.fill"
        case .rising: return "chart.line.uptrend.xyaxis"
        case .top: return "arrow.up.circle.fill"
        case .controversial: return "bolt.fill"
        }
    }
}

enum TimeFilter: String, CaseIterable, Sendable {
    case hour = "hour"
    case day = "day"
    case week = "week"
    case month = "month"
    case year = "year"
    case all = "all"

    var displayName: String {
        switch self {
        case .hour: return "Hour"
        case .day: return "Day"
        case .week: return "Week"
        case .month: return "Month"
        case .year: return "Year"
        case .all: return "All"
        }
    }
}

enum RedditError: LocalizedError, Sendable {
    case networkError(Error)
    case invalidResponse
    case unauthorized
    case rateLimited
    case decodingError(Error)
    case tokenExpired
    case unknown(String)

    var errorDescription: String? {
        switch self {
        case .networkError: return "Network connection failed. Please check your internet."
        case .invalidResponse: return "Invalid response from Reddit."
        case .unauthorized: return "Please log in to continue."
        case .rateLimited: return "Too many requests. Please wait a moment."
        case .decodingError: return "Failed to parse Reddit data."
        case .tokenExpired: return "Session expired. Please log in again."
        case .unknown(let msg): return msg
        }
    }
}
