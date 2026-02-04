import Foundation
import SwiftData

@Model
final class PaymentLog {
    var id: UUID
    var amount: Double
    var currency: String
    var paidAt: Date
    var note: String
    var isSettled: Bool

    var paidBy: Member?
    var subscription: Subscription?

    init(
        id: UUID = UUID(),
        amount: Double,
        currency: String = "USD",
        paidAt: Date = Date(),
        note: String = "",
        isSettled: Bool = false,
        paidBy: Member? = nil,
        subscription: Subscription? = nil
    ) {
        self.id = id
        self.amount = amount
        self.currency = currency
        self.paidAt = paidAt
        self.note = note
        self.isSettled = isSettled
        self.paidBy = paidBy
        self.subscription = subscription
    }
}
