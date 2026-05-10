import Foundation

final class RateLimiter: @unchecked Sendable {
    private let maxRequests: Int
    private let interval: TimeInterval
    private let lock = NSLock()
    private var timestamps: [Date] = []

    init(maxRequests: Int = 95, perInterval: TimeInterval = 60) {
        self.maxRequests = maxRequests
        self.interval = perInterval
    }

    func canMakeRequest() -> Bool {
        lock.lock()
        defer { lock.unlock() }

        let now = Date()
        timestamps = timestamps.filter { now.timeIntervalSince($0) < interval }

        if timestamps.count < maxRequests {
            timestamps.append(now)
            return true
        }
        return false
    }

    func waitIfNeeded() async throws {
        if canMakeRequest() { return }

        let oldest = timestamps.min() ?? Date()
        let waitTime = interval - Date().timeIntervalSince(oldest) + 0.1
        if waitTime > 0 {
            try await Task.sleep(nanoseconds: UInt64(waitTime * 1_000_000_000))
            _ = canMakeRequest()
        }
    }
}
