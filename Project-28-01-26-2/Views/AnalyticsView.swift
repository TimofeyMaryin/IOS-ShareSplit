import SwiftUI
import SwiftData
import Charts

struct AnalyticsView: View {
    @Query(filter: #Predicate<Subscription> { $0.isActive })
    private var subscriptions: [Subscription]
    @Query private var settingsList: [AppSettings]
    @Query(sort: \Member.name)
    private var members: [Member]

    private var settings: AppSettings? { settingsList.first }

    private var spendingByCategory: [(SubscriptionCategory, Double)] {
        let grouped = Dictionary(grouping: subscriptions) { $0.category }
        return SubscriptionCategory.allCases.compactMap { cat in
            let total = (grouped[cat] ?? []).reduce(0) { $0 + $1.monthlyEquivalent }
            return total > 0 ? (cat, total) : nil
        }
    }

    private var totalMonthlyCost: Double {
        subscriptions.reduce(0) { $0 + $1.monthlyEquivalent }
    }

    private var currentUserMember: Member? {
        let name = settings?.userName.trimmingCharacters(in: .whitespaces) ?? ""
        guard !name.isEmpty else { return nil }
        return members.first { $0.name.localizedCaseInsensitiveCompare(name) == .orderedSame }
    }

    private var userShareTotal: Double {
        guard let me = currentUserMember else { return 0 }
        return me.shares.reduce(0) { $0 + $1.amount }
    }

    private var moneySaved: Double {
        max(0, totalMonthlyCost - userShareTotal)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    moneySavedCard
                    if !spendingByCategory.isEmpty {
                        categoryChartSection
                    }
                }
                .padding()
            }
            .navigationTitle("Analytics")
            .background(Color(.systemGroupedBackground))
        }
    }

    private var moneySavedCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "dollarsign.arrow.circlepath")
                    .foregroundStyle(.green)
                Text("Money saved")
                    .font(.headline)
                Spacer()
            }
            Text(Formatters.currency(moneySaved))
                .font(.title.bold())
                .foregroundStyle(.green)
            Text(currentUserMember != nil
                 ? "Total subscription cost and your share this month"
                 : "Enter your name in Settings to see your share vs total.")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var categoryChartSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Spending by category")
                .font(.headline)
            Chart(spendingByCategory, id: \.0) { item in
                SectorMark(
                    angle: .value("Amount", item.1),
                    innerRadius: .ratio(0.5),
                    angularInset: 2
                )
                .foregroundStyle(by: .value("Category", item.0.displayName))
            }
            .frame(height: 220)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    AnalyticsView()
        .modelContainer(for: [Subscription.self], inMemory: true)
}
