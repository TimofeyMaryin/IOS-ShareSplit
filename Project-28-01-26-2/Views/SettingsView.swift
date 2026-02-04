import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var settingsList: [AppSettings]
    @AppStorage("appTheme") private var appThemeRaw: String = AppTheme.system.rawValue

    private var settings: AppSettings? { settingsList.first }

    @State private var defaultCurrency: String = "USD"
    @State private var nameInReminders: String = ""
    @State private var saved = false
    @State private var hasEnsuredSettings = false

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Picker("Theme", selection: $appThemeRaw) {
                        ForEach(AppTheme.allCases, id: \.rawValue) { theme in
                            Text(theme.displayName).tag(theme.rawValue)
                        }
                    }
                    .pickerStyle(.menu)
                } header: {
                    Text("Appearance")
                } footer: {
                    Text("System follows your iPhone settings.")
                }
                Section {
                    Picker("Default currency", selection: $defaultCurrency) {
                        ForEach(CurrencyOptions.all) { option in
                            Text(option.code).tag(option.code)
                        }
                    }
                    .pickerStyle(.menu)
                    TextField("Name in reminders", text: $nameInReminders, prompt: Text("Optional"))
                } header: {
                    Text("App")
                } footer: {
                    Text("Default currency is used when creating subscriptions. Your name in reminders is how you're referred to in the text (e.g. \"Send to [name]\"). Card and payment details are not stored.")
                }
                if saved {
                    Section {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(.green)
                            Text("Saved")
                                .foregroundStyle(.green)
                        }
                    }
                }
                Section {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0")
                            .foregroundStyle(.secondary)
                    }
                } header: {
                    Text("About")
                }
            }
            .navigationTitle("Settings")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                }
            }
            .onAppear {
                ensureSingleSettings()
                loadSettingsIntoState()
            }
            .onChange(of: settingsList.count) { _, _ in
                loadSettingsIntoState()
            }
        }
    }

    private func loadSettingsIntoState() {
        if let s = settingsList.first {
            defaultCurrency = s.resolvedDefaultCurrency
            nameInReminders = s.userName
        }
    }

    private func ensureSingleSettings() {
        if hasEnsuredSettings { return }
        hasEnsuredSettings = true
        if settingsList.isEmpty {
            let newSettings = AppSettings(defaultCurrency: "USD", userName: "")
            modelContext.insert(newSettings)
            try? modelContext.save()
        } else if settingsList.count > 1 {
            // Keep the single most recent record by updatedAt, delete the rest
            let kept = settingsList.sorted { $0.updatedAt > $1.updatedAt }.first!
            for s in settingsList where s.id != kept.id {
                modelContext.delete(s)
            }
            try? modelContext.save()
        }
    }

    private func save() {
        let current = settingsList.first
        if let s = current {
            s.defaultCurrency = defaultCurrency
            s.userName = nameInReminders
            s.updatedAt = Date()
        } else {
            let newSettings = AppSettings(
                defaultCurrency: defaultCurrency,
                userName: nameInReminders
            )
            modelContext.insert(newSettings)
        }
        try? modelContext.save()
        saved = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { saved = false }
    }
}

#Preview {
    SettingsView()
        .modelContainer(for: [AppSettings.self], inMemory: true)
}
