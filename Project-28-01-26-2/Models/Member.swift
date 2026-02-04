import Foundation
import SwiftData

@Model
final class Member {
    var id: UUID
    var name: String
    var email: String
    var phone: String
    /// Running balance: positive = they owe, negative = they are owed
    var totalBalance: Double
    var createdAt: Date

    @Relationship(deleteRule: .nullify, inverse: \Share.member)
    var shares: [Share] = []

    @Relationship(deleteRule: .nullify, inverse: \PaymentLog.paidBy)
    var paymentsMade: [PaymentLog] = []

    init(
        id: UUID = UUID(),
        name: String,
        email: String = "",
        phone: String = "",
        totalBalance: Double = 0,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.email = email
        self.phone = phone
        self.totalBalance = totalBalance
        self.createdAt = createdAt
    }
}
