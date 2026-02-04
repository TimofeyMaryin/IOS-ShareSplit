import SwiftUI
import SwiftData

struct AddEditMemberView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let member: Member?

    @State private var name: String = ""
    @State private var email: String = ""
    @State private var phone: String = ""

    var isEditing: Bool { member != nil }

    var body: some View {
        NavigationStack {
            Form {
                Section("Contact") {
                    TextField("Name", text: $name)
                    TextField("Email", text: $email)
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)
                    TextField("Phone", text: $phone)
                        .textContentType(.telephoneNumber)
                        .keyboardType(.phonePad)
                }
            }
            .navigationTitle(isEditing ? "Edit member" : "New member")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .onAppear {
                if let m = member {
                    name = m.name
                    email = m.email
                    phone = m.phone
                }
            }
        }
    }

    private func save() {
        let trimmedName = name.trimmingCharacters(in: .whitespaces)
        guard !trimmedName.isEmpty else { return }
        if let m = member {
            m.name = trimmedName
            m.email = email
            m.phone = phone
        } else {
            let newMember = Member(name: trimmedName, email: email, phone: phone)
            modelContext.insert(newMember)
        }
        try? modelContext.save()
        dismiss()
    }
}

#Preview {
    AddEditMemberView(member: nil)
        .modelContainer(for: [Member.self], inMemory: true)
}
