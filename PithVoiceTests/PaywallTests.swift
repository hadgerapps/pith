import Foundation
@testable import PithVoice
import Testing

@Suite("Paywall")
@MainActor
struct PaywallTests {
    @Test("Free allowance is 2 entries per FR-31")
    func freeAllowance() {
        #expect(PaywallController.freeEntryAllowance == 2)
    }

    @Test("Product IDs match SPEC canonical naming")
    func productIDs() {
        #expect(ProductCatalog.ProductID.weekly == "com.hadger.pith.sub.weekly")
        #expect(ProductCatalog.ProductID.annual == "com.hadger.pith.sub.annual")
        #expect(ProductCatalog.ProductID.lifetime == "com.hadger.pith.iap.lifetime")
        #expect(ProductCatalog.ProductID.all.count == 3)
    }

    @Test("Lifetime entitlement is active without expiry")
    func lifetimeIsAlwaysActive() {
        let entitlement = Entitlement(kind: .lifetime, expiresAt: nil)
        #expect(entitlement.isActive)
    }

    @Test("Expired annual entitlement is inactive")
    func expiredAnnualInactive() {
        let entitlement = Entitlement(
            kind: .annual,
            expiresAt: Date().addingTimeInterval(-1)
        )
        #expect(!entitlement.isActive)
    }

    @Test("Future annual entitlement is active")
    func futureAnnualActive() {
        let entitlement = Entitlement(
            kind: .annual,
            expiresAt: Date().addingTimeInterval(86_400)
        )
        #expect(entitlement.isActive)
    }

    @Test("EntitlementKind round-trips through raw value")
    func entitlementKindRawValue() {
        #expect(EntitlementKind(rawValue: "weekly") == .weekly)
        #expect(EntitlementKind(rawValue: "annual") == .annual)
        #expect(EntitlementKind(rawValue: "lifetime") == .lifetime)
        #expect(EntitlementKind.weekly.rawValue == "weekly")
    }
}
