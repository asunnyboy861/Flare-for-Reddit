import Foundation
import StoreKit

@Observable
final class PurchaseManager: @unchecked Sendable {
    static let shared = PurchaseManager()

    var products: [Product] = []
    var purchasedProductIDs: Set<String> = []
    var isProUser: Bool = false
    var isLoading = false

    private var transactionListener: Task<Void, Never>?

    private let productIDs = [
        "com.zzoutuo.FlareForReddit.pro.monthly",
        "com.zzoutuo.FlareForReddit.pro.yearly",
        "com.zzoutuo.FlareForReddit.pro.lifetime"
    ]

    private init() {
        transactionListener = listenForTransactions()
        Task {
            await loadProducts()
            await updatePurchasedProducts()
        }
    }

    deinit {
        transactionListener?.cancel()
    }

    @MainActor
    func loadProducts() async {
        do {
            products = try await Product.products(for: productIDs)
            products.sort { $0.price < $1.price }
        } catch {
            print("Failed to load products: \(error)")
        }
    }

    @MainActor
    func purchase(_ product: Product) async -> Bool {
        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                let transaction = try checkVerified(verification)
                purchasedProductIDs.insert(transaction.productID)
                isProUser = true
                await transaction.finish()
                return true
            case .userCancelled:
                return false
            case .pending:
                return false
            @unknown default:
                return false
            }
        } catch {
            print("Purchase failed: \(error)")
            return false
        }
    }

    @MainActor
    func restorePurchases() async {
        do {
            try await AppStore.sync()
            await updatePurchasedProducts()
        } catch {
            print("Restore failed: \(error)")
        }
    }

    private func listenForTransactions() -> Task<Void, Never> {
        Task.detached { [weak self] in
            for await result in Transaction.updates {
                do {
                    let transaction = try self?.checkVerified(result)
                    await self?.updatePurchasedProducts()
                    await transaction?.finish()
                } catch {
                    print("Transaction verification failed: \(error)")
                }
            }
        }
    }

    @MainActor
    private func updatePurchasedProducts() async {
        var purchasedIDs: Set<String> = []

        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result {
                if productIDs.contains(transaction.productID) {
                    purchasedIDs.insert(transaction.productID)
                    await transaction.finish()
                }
            }
        }

        purchasedProductIDs = purchasedIDs
        isProUser = !purchasedIDs.isEmpty
    }

    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw StoreError.verificationFailed
        case .verified(let safe):
            return safe
        }
    }

    enum StoreError: Error {
        case verificationFailed
    }
}
