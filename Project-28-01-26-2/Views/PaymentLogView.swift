import SwiftUI
import SwiftData

struct PaymentLogView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \PaymentLog.paidAt, order: .reverse)
    private var logs: [PaymentLog]

    @State private var showingAddPayment = false

    var body: some View {
        NavigationStack {
            TimelineView(.periodic(from: .now, by: 10)) { _ in
                Group {
                    if logs.isEmpty {
                        EmptyPaymentLogView(onAdd: { showingAddPayment = true })
                    } else {
                        List {
                            ForEach(logs) { log in
                                PaymentLogRowView(log: log)
                                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                        if !log.isSettled {
                                            Button {
                                                markSettled(log)
                                            } label: {
                                                Label("Settled", systemImage: "checkmark.circle.fill")
                                            }
                                            .tint(.green)
                                        }
                                    }
                            }
                        }
                        .listStyle(.insetGrouped)
                    }
                }
            }
            .navigationTitle("Payment history")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingAddPayment = true
                    } label: {
                        Image(systemName: "plus.circle")
                    }
                }
            }
            .sheet(isPresented: $showingAddPayment) {
                AddPaymentLogView()
            }
        }
    }

    private func markSettled(_ log: PaymentLog) {
        log.isSettled = true
        try? modelContext.save()
    }
}

struct PaymentLogRowView: View {
    let log: PaymentLog

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: log.isSettled ? "checkmark.circle.fill" : "circle")
                .foregroundStyle(log.isSettled ? Color.green : .secondary)
            VStack(alignment: .leading, spacing: 4) {
                Text(log.subscription?.serviceName ?? "—")
                    .font(.headline)
                Text(log.paidBy?.name ?? "—")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Text(Formatters.relativeDate(log.paidAt))
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 2) {
                Text(Formatters.currency(log.amount, currency: log.currency))
                    .font(.subheadline.bold())
                if log.isSettled {
                    Text("Settled")
                        .font(.caption2)
                        .foregroundStyle(.green)
                }
            }
        }
        .padding(.vertical, 4)
    }
}

struct EmptyPaymentLogView: View {
    var onAdd: (() -> Void)?

    var body: some View {
        ContentUnavailableView {
            Label("No payments yet", systemImage: "clock.arrow.circlepath")
        } description: {
            Text("Payment entries will appear here once you add them.")
        } actions: {
            Button("Add payment") {
                onAdd?()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}

#Preview {
    PaymentLogView()
        .modelContainer(for: [PaymentLog.self, Member.self, Subscription.self], inMemory: true)
}
