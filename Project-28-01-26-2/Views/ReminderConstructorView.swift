import SwiftUI
import SwiftData

struct ReminderConstructorView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var settingsList: [AppSettings]

    let subscription: Subscription

    @State private var copiedFeedback = false

    private var settings: AppSettings? { settingsList.first }

    var body: some View {
        List {
            Section("Preview") {
                Text(messagePreview)
                    .textSelection(.enabled)
                    .padding(.vertical, 8)
            }
            Section("Actions") {
                Button {
                    copyToClipboard()
                } label: {
                    Label(copiedFeedback ? "Copied!" : "Copy", systemImage: copiedFeedback ? "checkmark.circle.fill" : "doc.on.doc")
                }
                .disabled(messagePreview.isEmpty || messagePreview.hasPrefix("Add members"))
                ShareLink(item: messagePreview) {
                    Label("Share", systemImage: "square.and.arrow.up")
                }
                .disabled(messagePreview.isEmpty || messagePreview.hasPrefix("Add members"))
            }
        }
        .navigationTitle("Reminder")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func copyToClipboard() {
        let text = messagePreview
        guard !text.isEmpty, !text.hasPrefix("Add members") else { return }
        UIPasteboard.general.string = text
        copiedFeedback = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { copiedFeedback = false }
    }

    private var messagePreview: String {
        let contactName = settings?.userName.isEmpty == false ? settings!.userName : "the organizer"
        let lines = subscription.shares.compactMap { share -> String? in
            guard let member = share.member else { return nil }
            return "Hi \(member.name)! Your share for \(subscription.serviceName) is \(Formatters.currency(share.amount, currency: subscription.currency)). Please send it to \(contactName)."
        }
        return lines.isEmpty
            ? "Add members to this subscription to build reminders."
            : lines.joined(separator: "\n\n")
    }
}

#Preview {
    NavigationStack {
        ReminderConstructorView(subscription: Subscription(
            serviceName: "Netflix",
            totalCost: 15.99,
            currency: "USD"
        ))
    }
    .modelContainer(for: [Subscription.self, Share.self, Member.self, AppSettings.self], inMemory: true)
}
