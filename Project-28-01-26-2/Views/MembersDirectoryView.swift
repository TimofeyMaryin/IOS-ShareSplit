import SwiftUI
import SwiftData

struct MembersDirectoryView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Member.name)
    private var members: [Member]

    @State private var showingAddMember = false
    @State private var memberToEdit: Member?
    @State private var memberToDelete: Member?
    @State private var showDeleteConfirm = false

    var body: some View {
        NavigationStack {
            Group {
                if members.isEmpty {
                    EmptyMembersView(onAdd: { showingAddMember = true })
                } else {
                    List {
                        ForEach(members) { member in
                            MemberRowView(member: member)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    memberToEdit = member
                                }
                                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                    Button(role: .destructive) {
                                        memberToDelete = member
                                        showDeleteConfirm = true
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                        }
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle("Members")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingAddMember = true
                    } label: {
                        Image(systemName: "person.badge.plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddMember) {
                AddEditMemberView(member: nil)
            }
            .sheet(item: $memberToEdit) { member in
                AddEditMemberView(member: member)
            }
            .alert("Delete member?", isPresented: $showDeleteConfirm) {
                Button("Cancel", role: .cancel) { memberToDelete = nil }
                Button("Delete", role: .destructive) {
                    if let member = memberToDelete {
                        deleteMember(member)
                    }
                    memberToDelete = nil
                }
            } message: {
                if let member = memberToDelete, !member.shares.isEmpty {
                    Text("This member has shares in \(member.shares.count) subscription(s). They will be removed from these subscriptions. This cannot be undone.")
                } else {
                    Text("The member will be deleted. This cannot be undone.")
                }
            }
        }
    }

    private func deleteMember(_ member: Member) {
        // Collect subscriptions that have this member's shares (before removing shares)
        let affectedSubscriptions = Set(member.shares.compactMap { $0.subscription })

        // Remove member's shares
        for share in member.shares {
            modelContext.delete(share)
        }
        try? modelContext.save()

        // Update totalCost for affected subscriptions: sum of remaining shares = new total cost
        for subscription in affectedSubscriptions {
            let sumOfShares = subscription.shares.reduce(0) { $0 + $1.amount }
            subscription.totalCost = sumOfShares
        }

        modelContext.delete(member)
        try? modelContext.save()
    }
}

struct MemberRowView: View {
    let member: Member

    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(balanceColor.opacity(0.2))
                .frame(width: 44, height: 44)
                .overlay {
                    Text(member.name.prefix(1).uppercased())
                        .font(.headline)
                        .foregroundStyle(balanceColor)
                }

            VStack(alignment: .leading, spacing: 4) {
                Text(member.name)
                    .font(.headline)
                if !member.email.isEmpty {
                    Text(member.email)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            Text(Formatters.currency(member.totalBalance))
                .font(.subheadline.bold())
                .foregroundStyle(balanceColor)
        }
        .padding(.vertical, 4)
    }

    private var balanceColor: Color {
        if member.totalBalance > 0 { return Color.red }
        if member.totalBalance < 0 { return Color.green }
        return Color.secondary
    }
}

struct EmptyMembersView: View {
    var onAdd: (() -> Void)?

    var body: some View {
        ContentUnavailableView {
            Label("No members", systemImage: "person.2")
        } description: {
            Text("Add friends or contacts you share subscriptions with.")
        } actions: {
            Button("Add member") {
                onAdd?()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}

#Preview {
    MembersDirectoryView()
        .modelContainer(for: [Member.self], inMemory: true)
}
