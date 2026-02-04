import SwiftUI
import SwiftData

/// Theme key and values in UserDefaults
enum AppTheme: String, CaseIterable {
    case light = "light"
    case dark = "dark"
    case system = "system"

    var displayName: String {
        switch self {
        case .light: return "Light"
        case .dark: return "Dark"
        case .system: return "System"
        }
    }

    var colorScheme: ColorScheme? {
        switch self {
        case .light: return .light
        case .dark: return .dark
        case .system: return nil
        }
    }
}

struct ContentView: View {
    @AppStorage("appTheme") private var appThemeRaw: String = AppTheme.system.rawValue

    private var resolvedColorScheme: ColorScheme? {
        AppTheme(rawValue: appThemeRaw)?.colorScheme ?? nil
    }

    var body: some View {
        TabView {
            SubscriptionsHubView()
                .tabItem {
                    Label("Subscriptions", systemImage: "creditcard.fill")
                }
            MembersDirectoryView()
                .tabItem {
                    Label("Members", systemImage: "person.2.fill")
                }
            PaymentLogView()
                .tabItem {
                    Label("History", systemImage: "clock.arrow.circlepath")
                }
            AnalyticsView()
                .tabItem {
                    Label("Analytics", systemImage: "chart.pie.fill")
                }
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
        }
        .tint(.accentColor)
        .preferredColorScheme(resolvedColorScheme)
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [
            Member.self,
            Subscription.self,
            Share.self,
            PaymentLog.self,
            AppSettings.self
        ], inMemory: true)
}
