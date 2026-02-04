import Foundation
import SwiftData

@Model
final class AppSettings {
    var id: UUID
    /// Optional for migration: old store had no this attribute; nil is treated as "USD".
    var defaultCurrency: String?
    var userName: String  // Name shown in reminders (e.g. "Contact [name] to pay")
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        defaultCurrency: String? = "USD",
        userName: String = "",
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.defaultCurrency = defaultCurrency
        self.userName = userName
        self.updatedAt = updatedAt
    }

    /// Resolved currency for display and logic (nil from migrated data → "USD").
    var resolvedDefaultCurrency: String {
        (defaultCurrency?.trimmingCharacters(in: .whitespaces)).flatMap { $0.isEmpty ? nil : $0 } ?? "USD"
    }
}
