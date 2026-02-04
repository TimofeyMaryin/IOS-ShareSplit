import SwiftUI
import SwiftData

struct EditSubscriptionView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Bindable var subscription: Subscription

    @Query(sort: \Member.name)
    private var allMembers: [Member]

    @State private var nextBillingDate: Date = Date()
    @State private var totalCost: Double = 0
    @State private var currency: String = "USD"
    @State private var memberToAddId: UUID?
    @State private var newMemberAmount: Double = 0

    private var currentSharesSum: Double {
        subscription.shares.reduce(0) { $0 + $1.amount }
    }

    private var sharesValid: Bool {
        let diff = abs(currentSharesSum - totalCost)
        return diff < 0.01
    }

    private var membersNotInSubscription: [Member] {
        let inIds = Set(subscription.shares.compactMap { $0.member?.id })
        return allMembers.filter { !inIds.contains($0.id) }
    }

    var body: some View {
        Form {
                Section("Payment") {
                    DatePicker("Next billing date", selection: $nextBillingDate, displayedComponents: .date)
                    TextField("Total cost", value: $totalCost, format: .number)
                        .keyboardType(.decimalPad)
                    TextField("Currency", text: $currency)
                }

                Section("Members and shares") {
                    ForEach(subscription.shares) { share in
                        if let member = share.member {
                            HStack {
                                Text(member.name)
                                Spacer()
                                TextField("Amount", value: Binding(
                                    get: { share.amount },
                                    set: { newVal in
                                        let delta = newVal - share.amount
                                        share.amount = newVal
                                        member.totalBalance += delta
                                    }
                                ), format: .number)
                                .keyboardType(.decimalPad)
                                .multilineTextAlignment(.trailing)
                                .frame(width: 80)
                                Button(role: .destructive) {
                                    removeShare(share, member: member)
                                } label: {
                                    Image(systemName: "minus.circle.fill")
                                }
                            }
                        }
                    }
                    HStack {
                        Text("Total")
                        Spacer()
                        Text(Formatters.currency(currentSharesSum, currency: currency))
                            .foregroundStyle(sharesValid ? Color.green : Color.red)
                    }
                }

                Section("Equal split") {
                    Button("Recalculate equal shares") {
                        recalcEqualShares()
                    }
                    .disabled(subscription.shares.isEmpty)
                }

                if !membersNotInSubscription.isEmpty {
                    Section("Add member") {
                        Picker("Member", selection: $memberToAddId) {
                            Text("Choose…").tag(nil as UUID?)
                            ForEach(membersNotInSubscription) { member in
                                Text(member.name).tag(member.id as UUID?)
                            }
                        }
                        TextField("Amount", value: $newMemberAmount, format: .number)
                            .keyboardType(.decimalPad)
                        Button("Add") {
                            addSelectedMember()
                        }
                        .disabled(memberToAddId == nil || newMemberAmount <= 0)
                    }
                }
            }
            .navigationTitle("Edit subscription")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .disabled(!sharesValid)
                }
            }
            .onAppear {
                nextBillingDate = subscription.nextBillingDate
                totalCost = subscription.totalCost
                currency = subscription.currency
            }
    }

    private func removeShare(_ share: Share, member: Member) {
        member.totalBalance -= share.amount
        modelContext.delete(share)
        try? modelContext.save()
    }

    private func addSelectedMember() {
        guard let id = memberToAddId,
              let member = allMembers.first(where: { $0.id == id }) else { return }
        let share = Share(
            amount: newMemberAmount,
            isFixed: true,
            member: member,
            subscription: subscription
        )
        modelContext.insert(share)
        member.shares.append(share)
        subscription.shares.append(share)
        member.totalBalance += newMemberAmount
        try? modelContext.save()
        memberToAddId = nil
        newMemberAmount = 0
    }

    private func recalcEqualShares() {
        let count = subscription.shares.count
        guard count > 0 else { return }
        let perPerson = totalCost / Double(count)
        for share in subscription.shares {
            if let member = share.member {
                let delta = perPerson - share.amount
                share.amount = perPerson
                member.totalBalance += delta
            }
        }
        try? modelContext.save()
    }

    private func save() {
        subscription.nextBillingDate = nextBillingDate
        subscription.totalCost = totalCost
        subscription.currency = currency
        try? modelContext.save()
        dismiss()
    }
}

#Preview {
    EditSubscriptionView(subscription: Subscription(
        serviceName: "Netflix",
        totalCost: 15.99,
        currency: "USD"
    ))
    .modelContainer(for: [Subscription.self, Member.self, Share.self], inMemory: true)
}
