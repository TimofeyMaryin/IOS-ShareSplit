import Foundation
import SwiftData

@Model
final class Share {
    var id: UUID
    var amount: Double
    var isFixed: Bool

    var member: Member?
    var subscription: Subscription?

    init(
        id: UUID = UUID(),
        amount: Double,
        isFixed: Bool = false,
        member: Member? = nil,
        subscription: Subscription? = nil
    ) {
        self.id = id
        self.amount = amount
        self.isFixed = isFixed
        self.member = member
        self.subscription = subscription
    }
}
