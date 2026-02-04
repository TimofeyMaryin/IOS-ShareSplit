import Foundation
import SwiftData

enum BillingCycle: String, Codable, CaseIterable {
    case monthly = "Monthly"
    case yearly = "Yearly"

    var displayName: String { rawValue }
}

@Model
final class Subscription {
    var id: UUID
    var serviceName: String
    var iconName: String
    var totalCost: Double
    var currency: String
    var billingCycleRaw: String
    var categoryRaw: String
    var nextBillingDate: Date
    var createdAt: Date
    var isActive: Bool

    var billingCycle: BillingCycle {
        get { BillingCycle(rawValue: billingCycleRaw) ?? .monthly }
        set { billingCycleRaw = newValue.rawValue }
    }

    var category: SubscriptionCategory {
        get { SubscriptionCategory(rawValue: categoryRaw) ?? .other }
        set { categoryRaw = newValue.rawValue }
    }

    @Relationship(deleteRule: .cascade, inverse: \Share.subscription)
    var shares: [Share] = []

    @Relationship(deleteRule: .cascade, inverse: \PaymentLog.subscription)
    var paymentLogs: [PaymentLog] = []

    init(
        id: UUID = UUID(),
        serviceName: String,
        iconName: String = "creditcard.fill",
        totalCost: Double,
        currency: String = "USD",
        billingCycle: BillingCycle = .monthly,
        category: SubscriptionCategory = .media,
        nextBillingDate: Date = Date(),
        createdAt: Date = Date(),
        isActive: Bool = true
    ) {
        self.id = id
        self.serviceName = serviceName
        self.iconName = iconName
        self.totalCost = totalCost
        self.currency = currency
        self.billingCycleRaw = billingCycle.rawValue
        self.categoryRaw = category.rawValue
        self.nextBillingDate = nextBillingDate
        self.createdAt = createdAt
        self.isActive = isActive
    }

    /// Monthly equivalent cost for display (burn rate)
    var monthlyEquivalent: Double {
        switch billingCycle {
        case .monthly: return totalCost
        case .yearly: return totalCost / 12
        }
    }
}
