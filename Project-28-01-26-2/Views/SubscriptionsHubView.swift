import SwiftUI
import SwiftData

struct SubscriptionsHubView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(filter: #Predicate<Subscription> { $0.isActive }, sort: \Subscription.nextBillingDate)
    private var subscriptions: [Subscription]

    var totalMonthlyBurn: Double {
        subscriptions.reduce(0) { $0 + $1.monthlyEquivalent }
    }

    var body: some View {
        NavigationStack {
            Group {
                if subscriptions.isEmpty {
                    EmptySubscriptionsView()
                } else {
                    List {
                        Section {
                            burnRateCard
                        }
                        .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                        .listRowBackground(Color.clear)

                        Section("Active subscriptions") {
                            ForEach(subscriptions) { sub in
                                NavigationLink(value: sub) {
                                    SubscriptionRowView(subscription: sub)
                                }
                                .listRowBackground(Color(.secondarySystemGroupedBackground))
                            }
                        }
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle("ShareSplit")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    NavigationLink(value: "new_subscription") {
                        Image(systemName: "plus.circle.fill")
                    }
                }
            }
            .navigationDestination(for: Subscription.self) { sub in
                SubscriptionDetailView(subscription: sub)
            }
            .navigationDestination(for: String.self) { value in
                if value == "new_subscription" {
                    NewSubscriptionFlowView()
                }
            }
        }
    }

    private var burnRateCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "flame.fill")
                    .foregroundStyle(.orange)
                Text("Monthly burn")
                    .font(.headline)
                Spacer()
            }
            Text(Formatters.currency(totalMonthlyBurn))
                .font(.title2.bold())
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.tertiarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

struct SubscriptionRowView: View {
    let subscription: Subscription

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: subscription.iconName)
                .font(.title2)
                .foregroundStyle(.blue)
                .frame(width: 36, height: 36)
                .background(Color.blue.opacity(0.15))
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 4) {
                Text(subscription.serviceName)
                    .font(.headline)
                Text("Next: \(Formatters.shortDate(subscription.nextBillingDate))")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text(Formatters.currency(subscription.totalCost, currency: subscription.currency))
                    .font(.subheadline.bold())
                countdownView
            }
        }
        .padding(.vertical, 4)
    }

    private var countdownView: some View {
        let days = Formatters.daysUntil(subscription.nextBillingDate)
        return Text(days >= 0 ? "\(days) days" : "Overdue")
            .font(.caption2)
            .foregroundStyle(days <= 3 ? Color.red : .secondary)
    }
}

struct EmptySubscriptionsView: View {
    var body: some View {
        ContentUnavailableView {
            Label("No subscriptions", systemImage: "creditcard")
        } description: {
            Text("Add a shared subscription to track shares and payments.")
        } actions: {
            NavigationLink(value: "new_subscription") {
                Text("Add subscription")
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}

#Preview {
    SubscriptionsHubView()
        .modelContainer(for: [Subscription.self, Member.self, Share.self, PaymentLog.self], inMemory: true)
}
