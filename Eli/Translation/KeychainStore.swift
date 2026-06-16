import Foundation
import Security

/// Stores the user's Gemini API key in the macOS Keychain — never in the
/// document, UserDefaults, or source. Bring-your-own-key, kept private.
enum KeychainStore {
    private static let service = "com.hatimhtm.eli"
    private static let account = "gemini-api-key"

    @discardableResult
    static func saveGeminiKey(_ key: String) -> Bool {
        let trimmed = key.trimmingCharacters(in: .whitespacesAndNewlines)
        let base: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]
        SecItemDelete(base as CFDictionary)
        guard !trimmed.isEmpty else { return true } // empty = cleared
        var add = base
        add[kSecValueData as String] = Data(trimmed.utf8)
        return SecItemAdd(add as CFDictionary, nil) == errSecSuccess
    }

    static func geminiKey() -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        var item: CFTypeRef?
        guard SecItemCopyMatching(query as CFDictionary, &item) == errSecSuccess,
              let data = item as? Data,
              let key = String(data: data, encoding: .utf8) else { return nil }
        return key
    }
}
