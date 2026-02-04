import SwiftUI
import SwiftData

struct NewSubscriptionFlowView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @Query(sort: \Member.name)
    private var allMembers: [Member]
    @Query private var settingsList: [AppSettings]

    @State private var step: Int = 0
    @State private var selectedPresetId: String = SubscriptionPresets.all.first!.id
    @State private var customServiceName: String = ""
    @State private var iconName: String = "creditcard.fill"
    @State private var totalCost: Double = 0
    @State private var currency: String = "USD"
    @State private var billingCycle: BillingCycle = .monthly
    @State private var category: SubscriptionCategory = .media
    @State private var splitMode: SplitMode = .equal
    @State private var selectedMemberIds: Set<UUID> = []
    @State private var customAmounts: [UUID: Double] = [:]
    @State private var nextBillingDate: Date = Calendar.current.date(byAdding: .month, value: 1, to: Date()) ?? Date()

    enum SplitMode: String, CaseIterable {
        case equal = "Equal"
        case custom = "Custom amounts"
    }

    var serviceName: String {
        if selectedPresetId == "custom" {
            return customServiceName.isEmpty ? "Custom service" : customServiceName
        }
        return SubscriptionPresets.preset(for: selectedPresetId)?.serviceName ?? "Custom service"
    }

    var effectiveIconName: String {
        if selectedPresetId == "custom" { return iconName }
        return SubscriptionPresets.preset(for: selectedPresetId)?.iconName ?? "creditcard.fill"
    }

    var selectedMembers: [Member] {
        allMembers.filter { selectedMemberIds.contains($0.id) }
    }

    var sumOfShares: Double {
        switch splitMode {
        case .equal:
            let count = max(selectedMembers.count, 1)
            return (totalCost / Double(count)) * Double(count)
        case .custom:
            return selectedMembers.reduce(0) { sum, m in sum + (customAmounts[m.id] ?? 0) }
        }
    }

    var isPriceValid: Bool {
        totalCost.isFinite && totalCost >= 0 && totalCost <= 999_999.99
    }

    var sharesValid: Bool {
        guard !selectedMembers.isEmpty, totalCost > 0 else { return false }
        let diff = abs(sumOfShares - totalCost)
        return diff < 0.01
    }

    var body: some View {
        VStack(spacing: 0) {
            stepIndicator
            stepHint
            Group {
                switch step {
                case 0: stepService
                case 1: stepPrice
                case 2: stepSplit
                default: stepService
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .navigationTitle("New subscription")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                if step < 2 {
                    Button("Next") { step += 1 }
                        .disabled(step == 0 ? false : (step == 1 ? !isPriceValid : !sharesValid))
                } else {
                    Button("Save") { saveSubscription() }
                        .disabled(!sharesValid)
                }
            }
        }
    }

    private var stepIndicator: some View {
        HStack(spacing: 8) {
            ForEach([0, 1, 2], id: \.self) { i in
                Circle()
                    .fill(i <= step ? Color.accentColor : Color.gray.opacity(0.3))
                    .frame(width: 8, height: 8)
            }
        }
        .padding(.vertical, 8)
    }

    private var stepHint: some View {
        Group {
            switch step {
            case 0:
                Text("Choose a service you share: pick a preset or add your own.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            case 1:
                Text("Enter the total cost and next billing date to make it easy to collect shares.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            case 2:
                Text("Select members and split the cost equally or enter custom amounts. The sum of shares must match the subscription price.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            default:
                EmptyView()
            }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 8)
    }

    private var stepService: some View {
        Form {
            Section {
                Picker("Preset", selection: $selectedPresetId) {
                    ForEach(SubscriptionPresets.all) { preset in
                        Label(preset.serviceName, systemImage: preset.iconName)
                            .tag(preset.id)
                    }
                }
                .pickerStyle(.menu)
                if selectedPresetId == "custom" {
                    TextField("Service name", text: $customServiceName, prompt: Text("e.g. Streaming"))
                    Picker("Icon", selection: $iconName) {
                        ForEach(SubscriptionIconOptions.all) { option in
                            Label(option.displayName, systemImage: option.iconName)
                                .tag(option.iconName)
                        }
                    }
                    .pickerStyle(.menu)
                    Picker("Category", selection: $category) {
                        ForEach(SubscriptionCategory.allCases, id: \.self) { cat in
                            Text(cat.displayName).tag(cat)
                        }
                    }
                }
            } header: {
                Text("Service")
            } footer: {
                Text("Name and icon will appear in the subscriptions list.")
            }
        }
        .onChange(of: selectedPresetId) { _, newId in
            if let preset = SubscriptionPresets.preset(for: newId), preset.id != "custom" {
                category = preset.category
            }
        }
        .onAppear {
            if step == 0 {
                currency = settingsList.first?.resolvedDefaultCurrency ?? "USD"
            }
        }
    }

    private var stepPrice: some View {
        Form {
            Section {
                TextField("Total cost", value: $totalCost, format: .number)
                    .keyboardType(.decimalPad)
                    .onChange(of: totalCost) { _, newValue in
                        if !newValue.isFinite || newValue < 0 {
                            totalCost = 0
                        } else if newValue > 999_999.99 {
                            totalCost = 999_999.99
                        }
                    }
                Picker("Currency", selection: $currency) {
                    ForEach(CurrencyOptions.all) { option in
                        Text(option.code).tag(option.code)
                    }
                }
                .pickerStyle(.menu)
                Picker("Billing period", selection: $billingCycle) {
                    ForEach(BillingCycle.allCases, id: \.self) { cycle in
                        Text(cycle.displayName).tag(cycle)
                    }
                }
                DatePicker("Next billing date", selection: $nextBillingDate, displayedComponents: .date)
            } header: {
                Text("Price and payment")
            } footer: {
                Text("Enter the full subscription amount. Billing date is used for reminders.")
            }
        }
    }

    private var stepSplit: some View {
        Group {
            if allMembers.isEmpty {
                stepSplitEmptyState
            } else {
                Form {
                    Section {
                        ForEach(allMembers) { member in
                            Toggle(isOn: Binding(
                                get: { selectedMemberIds.contains(member.id) },
                                set: { on in
                                    if on { selectedMemberIds.insert(member.id) }
                                    else {
                                        selectedMemberIds.remove(member.id)
                                        customAmounts.removeValue(forKey: member.id)
                                    }
                                }
                            )) {
                                Text(member.name)
                            }
                        }
                    } header: {
                        Text("Members")
                    } footer: {
                        Text("Include everyone who uses this subscription.")
                    }
                    if !selectedMembers.isEmpty {
                        Section {
                            Picker("Mode", selection: $splitMode) {
                                ForEach(SplitMode.allCases, id: \.self) { mode in
                                    Text(mode.rawValue).tag(mode)
                                }
                            }
                            .pickerStyle(.segmented)
                            if splitMode == .equal {
                                let perPerson = totalCost / Double(selectedMembers.count)
                                HStack {
                                    Text("Per person")
                                    Spacer()
                                    Text(Formatters.currency(perPerson, currency: currency))
                                        .fontWeight(.medium)
                                }
                            } else {
                                ForEach(selectedMembers) { member in
                                    HStack {
                                        Text(member.name)
                                        Spacer()
                                        TextField("Amount", value: Binding(
                                            get: { customAmounts[member.id] ?? 0 },
                                            set: { customAmounts[member.id] = $0 }
                                        ), format: .number)
                                        .keyboardType(.decimalPad)
                                        .multilineTextAlignment(.trailing)
                                        .frame(width: 80)
                                    }
                                }
                                let sum = sumOfShares
                                HStack {
                                    Text("Total")
                                    Spacer()
                                    Text(Formatters.currency(sum, currency: currency))
                                        .fontWeight(.medium)
                                        .foregroundStyle(abs(sum - totalCost) < 0.01 ? Color.green : Color.red)
                                }
                            }
                        } header: {
                            Text("Split")
                        } footer: {
                            Text("Sum of shares must equal \(Formatters.currency(totalCost, currency: currency)).")
                        }
                    }
                }
            }
        }
    }

    private var stepSplitEmptyState: some View {
        ContentUnavailableView {
            Label("No members yet", systemImage: "person.2")
        } description: {
            Text("Add members in the Members tab first, then come back here and tap Next.")
        } actions: {
            Button("Back") {
                dismiss()
            }
            .buttonStyle(.bordered)
        }
        .padding()
    }

    private func saveSubscription() {
        let sub = Subscription(
            serviceName: serviceName,
            iconName: effectiveIconName,
            totalCost: totalCost,
            currency: currency,
            billingCycle: billingCycle,
            category: category,
            nextBillingDate: nextBillingDate
        )
        modelContext.insert(sub)

        let count = selectedMembers.count
        let amountPerPerson: Double
        if splitMode == .equal {
            amountPerPerson = count > 0 ? totalCost / Double(count) : 0
        } else {
            amountPerPerson = 0
        }

        for member in selectedMembers {
            let amount: Double
            if splitMode == .equal {
                amount = amountPerPerson
            } else {
                amount = customAmounts[member.id] ?? 0
            }
            let share = Share(amount: amount, isFixed: splitMode == .custom, member: member, subscription: sub)
            modelContext.insert(share)
            member.shares.append(share)
            sub.shares.append(share)
            member.totalBalance += amount
        }
        try? modelContext.save()
        dismiss()
    }
}

#Preview {
    NewSubscriptionFlowView()
        .modelContainer(for: [Subscription.self, Member.self, Share.self], inMemory: true)
}
