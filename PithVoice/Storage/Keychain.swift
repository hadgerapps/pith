import Foundation
import Security

/// Minimal Keychain wrapper for entitlement persistence.
///
/// Entitlement keys survive app reinstall — Keychain items are tied to the
/// keychain access group, not the app sandbox — which lets FR-33's reinstall
/// guard work. The `firstUseDate` key intentionally lingers so an
/// uninstall+reinstall cannot reset the 2-entry counter.
enum Keychain {
    enum Service { static let entitlement = "com.hadger.pith.entitlement" }

    @discardableResult
    static func set(_ data: Data, account: String, service: String = Service.entitlement) -> Bool {
        let baseQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
        ]
        SecItemDelete(baseQuery as CFDictionary)

        var attrs = baseQuery
        attrs[kSecValueData as String] = data
        attrs[kSecAttrAccessible as String] = kSecAttrAccessibleAfterFirstUnlock
        return SecItemAdd(attrs as CFDictionary, nil) == errSecSuccess
    }

    @discardableResult
    static func setString(_ value: String, account: String, service: String = Service.entitlement) -> Bool {
        set(Data(value.utf8), account: account, service: service)
    }

    @discardableResult
    static func setDate(_ date: Date, account: String, service: String = Service.entitlement) -> Bool {
        setString(ISO8601DateFormatter().string(from: date), account: account, service: service)
    }

    static func data(account: String, service: String = Service.entitlement) -> Data? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecMatchLimit as String: kSecMatchLimitOne,
            kSecReturnData as String: true,
        ]
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        guard status == errSecSuccess, let data = item as? Data else { return nil }
        return data
    }

    static func string(account: String, service: String = Service.entitlement) -> String? {
        guard let data = data(account: account, service: service) else { return nil }
        return String(data: data, encoding: .utf8)
    }

    static func date(account: String, service: String = Service.entitlement) -> Date? {
        guard let str = string(account: account, service: service) else { return nil }
        return ISO8601DateFormatter().date(from: str)
    }

    @discardableResult
    static func delete(account: String, service: String = Service.entitlement) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
        ]
        let status = SecItemDelete(query as CFDictionary)
        return status == errSecSuccess || status == errSecItemNotFound
    }
}
