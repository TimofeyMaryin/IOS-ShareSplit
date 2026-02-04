import Foundation

enum Formatters {
    private static let appLocale = Locale(identifier: "en_US")

    static func currency(_ amount: Double, currency: String = "USD") -> String {
        let formatter = NumberFormatter()
        formatter.locale = appLocale
        formatter.numberStyle = .currency
        formatter.currencyCode = currency
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2
        return formatter.string(from: NSNumber(value: amount)) ?? "\(currency) \(String(format: "%.2f", amount))"
    }

    static func daysUntil(_ date: Date) -> Int {
        Calendar.current.dateComponents([.day], from: Date(), to: date).day ?? 0
    }

    static func shortDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = appLocale
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }

    static func relativeDate(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.locale = appLocale
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}
