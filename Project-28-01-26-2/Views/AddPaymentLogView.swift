import SwiftUI
import SwiftData

struct AddPaymentLogView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @Query(sort: \Subscription.serviceName)
    private var subscriptions: [Subscription]
    @Query(sort: \Member.name)
    private var members: [Member]

    @State private var selectedSubscriptionId: UUID?
    @State private var selectedMemberId: UUID?
    @State private var amount: Double = 0
    @State private var currency: String = "USD"
    @State private var note: String = ""

    var selectedSubscription: Subscription? {
        subscriptions.first { $0.id == selectedSubscriptionId }
    }

    var selectedMember: Member? {
        members.first { $0.id == selectedMemberId }
    }

    var canSave: Bool {
        selectedSubscription != nil && selectedMember != nil && amount > 0
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Payment") {
                    Picker("Service", selection: $selectedSubscriptionId) {
                        Text("Choose…").tag(nil as UUID?)
                        ForEach(subscriptions.filter { $0.isActive }) { sub in
                            Text(sub.serviceName).tag(sub.id as UUID?)
                        }
                    }
                    Picker("Who paid", selection: $selectedMemberId) {
                        Text("Choose…").tag(nil as UUID?)
                        ForEach(members) { member in
                            Text(member.name).tag(member.id as UUID?)
                        }
                    }
                    TextField("Amount", value: $amount, format: .number)
                        .keyboardType(.decimalPad)
                    if let sub = selectedSubscription {
                        TextField("Currency", text: $currency)
                        Text("Total: \(Formatters.currency(sub.totalCost, currency: sub.currency))")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    TextField("Note (optional)", text: $note)
                }
            }
            .navigationTitle("Add payment")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .disabled(!canSave)
                }
            }
            .onChange(of: selectedSubscriptionId) { _, newValue in
                if let sub = subscriptions.first(where: { $0.id == newValue }) {
                    currency = sub.currency
                }
            }
        }
    }

    private func save() {
        guard let sub = selectedSubscription, let member = selectedMember else { return }
        let log = PaymentLog(
            amount: amount,
            currency: currency,
            note: note,
            isSettled: false,
            paidBy: member,
            subscription: sub
        )
        modelContext.insert(log)
        sub.paymentLogs.append(log)
        member.paymentsMade.append(log)
        member.totalBalance -= amount
        try? modelContext.save()
        dismiss()
    }
}

#Preview {
    AddPaymentLogView()
        .modelContainer(for: [Subscription.self, Member.self, PaymentLog.self], inMemory: true)
}
