import Foundation
import Observation
import StoreKit

// MARK: - PurchaseOutcome

enum PurchaseOutcome: Equatable {
    case succeeded(Entitlement)
    case pending
    case cancelled
    case failed(String)
}

// MARK: - PaywallController

/// Owns the FR-31 paywall-trigger counter and FR-32 purchase/verify path.
///
/// FR-31: paywall triggers on the 3rd Record attempt (N = 2 free entries).
/// `shouldPresentPaywall(currentEntryCount:)` is the single source of truth.
@MainActor
@Observable
final class PaywallController {
    static let freeEntryAllowance = 2

    private let entitlements: EntitlementStore
    private let catalog: ProductCatalog

    init(entitlements: EntitlementStore, catalog: ProductCatalog) {
        self.entitlements = entitlements
        self.catalog = catalog
    }

    /// True iff the user has no active entitlement AND has already used the
    /// 2-entry allowance. Idempotent — call before each Record tap.
    func shouldPresentPaywall(currentEntryCount: Int) -> Bool {
        guard !entitlements.isPaid else { return false }
        return currentEntryCount >= Self.freeEntryAllowance
    }

    /// Purchase a product. FR-32 verification + entitlement cache.
    func purchase(_ product: Product) async -> PurchaseOutcome {
        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                guard case .verified(let transaction) = verification else {
                    return .failed("Transaction could not be verified.")
                }
                await transaction.finish()
                await entitlements.refreshFromStoreKit()
                if let entitlement = entitlements.current {
                    return .succeeded(entitlement)
                }
                return .failed("Entitlement not found after purchase.")
            case .userCancelled:
                return .cancelled
            case .pending:
                return .pending
            @unknown default:
                return .failed("Unknown purchase result.")
            }
        } catch {
            return .failed(error.localizedDescription)
        }
    }

    /// Restore Purchases — required by App Review.
    func restore() async {
        try? await AppStore.sync()
        await entitlements.refreshFromStoreKit()
    }

    /// Listen for transaction updates outside an explicit purchase
    /// (e.g. parental approval, renewal, refund). Called from app launch.
    static func startTransactionObserver(entitlements: EntitlementStore) -> Task<Void, Never> {
        Task { @MainActor in
            for await result in Transaction.updates {
                guard case .verified(let transaction) = result else { continue }
                await transaction.finish()
                await entitlements.refreshFromStoreKit()
            }
        }
    }
}
