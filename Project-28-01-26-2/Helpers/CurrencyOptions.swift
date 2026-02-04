import Foundation

struct CurrencyOption: Identifiable {
    let id: String
    let code: String
    var displayName: String { "\(code)" }
}

enum CurrencyOptions {
    static let all: [CurrencyOption] = [
        CurrencyOption(id: "USD", code: "USD"),
        CurrencyOption(id: "EUR", code: "EUR"),
        CurrencyOption(id: "GBP", code: "GBP"),
        CurrencyOption(id: "RUB", code: "RUB"),
        CurrencyOption(id: "JPY", code: "JPY"),
        CurrencyOption(id: "CHF", code: "CHF"),
        CurrencyOption(id: "CAD", code: "CAD"),
        CurrencyOption(id: "AUD", code: "AUD"),
        CurrencyOption(id: "CNY", code: "CNY"),
        CurrencyOption(id: "KRW", code: "KRW"),
        CurrencyOption(id: "BRL", code: "BRL"),
        CurrencyOption(id: "INR", code: "INR"),
        CurrencyOption(id: "MXN", code: "MXN"),
        CurrencyOption(id: "PLN", code: "PLN"),
        CurrencyOption(id: "UAH", code: "UAH"),
    ]
}
