import Foundation
import Observation
import StoreKit

// MARK: - EntitlementKind

enum EntitlementKind: String, Codable, Equatable {
    case weekly
    case annual
    case lifetime
}

// MARK: - Entitlement

struct Entitlement: Equatable {
    let kind: EntitlementKind
    let expiresAt: Date?

    var isActive: Bool {
        if let expiresAt {
            return expiresAt > Date()
        }
        return true
    }
}

// MARK: - EntitlementStore

/// Keychain-backed entitlement persistence (FR-32, FR-33, FR-34).
///
/// Keys (SPEC § Monetization):
/// - `pith.entitlement.kind` — weekly / annual / lifetime
/// - `pith.entitlement.expiresAt` — ISO 8601 date string, nil for lifetime
/// - `pith.entitlement.firstUseDate` — ISO 8601, survives reinstall (FR-33)
@MainActor
@Observable
final class EntitlementStore {
    enum Key {
        static let kind = "pith.entitlement.kind"
        static let expiresAt = "pith.entitlement.expiresAt"
        static let firstUseDate = "pith.entitlement.firstUseDate"
    }

    private(set) var current: Entitlement?

    init() {
        current = load()
        if Keychain.date(account: Key.firstUseDate) == nil {
            Keychain.setDate(Date(), account: Key.firstUseDate)
        }
    }

    var isPaid: Bool {
        current?.isActive ?? false
    }

    /// Reinstall guard timestamp — survives app uninstall (FR-33).
    var firstUseDate: Date? {
        Keychain.date(account: Key.firstUseDate)
    }

    /// Cache the current entitlement after a successful purchase or restore.
    func save(_ entitlement: Entitlement) {
        Keychain.setString(entitlement.kind.rawValue, account: Key.kind)
        if let expiry = entitlement.expiresAt {
            Keychain.setDate(expiry, account: Key.expiresAt)
        } else {
            Keychain.delete(account: Key.expiresAt)
        }
        current = entitlement
    }

    /// Clear cached entitlement (used when StoreKit reports expiry).
    func clear() {
        Keychain.delete(account: Key.kind)
        Keychain.delete(account: Key.expiresAt)
        current = nil
    }

    /// Sync from StoreKit 2 — FR-32 verification path.
    func refreshFromStoreKit() async {
        var latest: Entitlement?
        for await result in Transaction.currentEntitlements {
            guard case .verified(let tx) = result else { continue }
            if let kind = entitlementKind(for: tx.productID) {
                let expires = tx.expirationDate
                latest = Entitlement(kind: kind, expiresAt: expires)
            }
        }
        if let latest {
            save(latest)
        } else if current != nil {
            clear()
        }
    }

    private func load() -> Entitlement? {
        guard let raw = Keychain.string(account: Key.kind),
              let kind = EntitlementKind(rawValue: raw) else { return nil }
        let expires = Keychain.date(account: Key.expiresAt)
        return Entitlement(kind: kind, expiresAt: expires)
    }

    private func entitlementKind(for productID: String) -> EntitlementKind? {
        switch productID {
        case ProductCatalog.ProductID.weekly: .weekly
        case ProductCatalog.ProductID.annual: .annual
        case ProductCatalog.ProductID.lifetime: .lifetime
        default: nil
        }
    }
}
