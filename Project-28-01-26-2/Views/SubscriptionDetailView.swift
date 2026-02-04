import SwiftUI
import SwiftData

struct SubscriptionDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var subscription: Subscription

    var body: some View {
        List {
            Section {
                headerCard
            }
            .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
            .listRowBackground(Color.clear)

            Section("Members and shares") {
                ForEach(subscription.shares) { share in
                    if let member = share.member {
                        HStack {
                            Text(member.name)
                            Spacer()
                            Text(Formatters.currency(share.amount, currency: subscription.currency))
                                .fontWeight(.medium)
                        }
                    }
                }
            }

            Section("Next billing") {
                HStack {
                    Text("Date")
                    Spacer()
                    Text(Formatters.shortDate(subscription.nextBillingDate))
                }
                HStack {
                    Text("Period")
                    Spacer()
                    Text(subscription.billingCycle.displayName)
                }
            }
        }
        .navigationTitle(subscription.serviceName)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Menu {
                    NavigationLink("Edit subscription") {
                        EditSubscriptionView(subscription: subscription)
                    }
                    NavigationLink("Send reminder") {
                        ReminderConstructorView(subscription: subscription)
                    }
                    Button("Mark inactive", role: .destructive) {
                        subscription.isActive = false
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
    }

    private var headerCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: subscription.iconName)
                    .font(.title)
                    .foregroundStyle(.blue)
                    .frame(width: 48, height: 48)
                    .background(Color.blue.opacity(0.15))
                    .clipShape(Circle())
                VStack(alignment: .leading, spacing: 4) {
                    Text(subscription.serviceName)
                        .font(.title2.bold())
                    Text(subscription.category.displayName)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
            }
            Divider()
            HStack {
                Text("Total cost")
                Spacer()
                Text(Formatters.currency(subscription.totalCost, currency: subscription.currency))
                    .font(.headline)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.tertiarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    NavigationStack {
        SubscriptionDetailView(subscription: Subscription(
            serviceName: "Netflix",
            iconName: "play.rectangle.fill",
            totalCost: 15.99,
            currency: "USD"
        ))
    }
    .modelContainer(for: [Subscription.self, Member.self, Share.self], inMemory: true)
}
