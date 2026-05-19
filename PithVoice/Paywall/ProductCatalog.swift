import Foundation
import Observation
import StoreKit

/// StoreKit 2 product loader for Pith Voice's 3 IAPs.
@MainActor
@Observable
final class ProductCatalog {
    enum ProductID {
        static let weekly = "com.hadger.pith.sub.weekly"
        static let annual = "com.hadger.pith.sub.annual"
        static let lifetime = "com.hadger.pith.iap.lifetime"
        static let all: [String] = [weekly, annual, lifetime]
    }

    private(set) var weekly: Product?
    private(set) var annual: Product?
    private(set) var lifetime: Product?
    private(set) var loadError: String?
    private(set) var isLoading = false

    func load() async {
        isLoading = true
        defer { isLoading = false }
        do {
            let products = try await Product.products(for: ProductID.all)
            for product in products {
                switch product.id {
                case ProductID.weekly: weekly = product
                case ProductID.annual: annual = product
                case ProductID.lifetime: lifetime = product
                default: break
                }
            }
            loadError = nil
        } catch {
            loadError = error.localizedDescription
        }
    }
}
