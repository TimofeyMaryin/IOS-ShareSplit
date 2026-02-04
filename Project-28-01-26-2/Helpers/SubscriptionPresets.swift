import Foundation
import SwiftData

struct SubscriptionPreset: Identifiable {
    let id: String
    let serviceName: String
    let iconName: String
    let category: SubscriptionCategory
}

enum SubscriptionPresets {
    static let all: [SubscriptionPreset] = [
        SubscriptionPreset(id: "netflix", serviceName: "Netflix", iconName: "play.rectangle.fill", category: .media),
        SubscriptionPreset(id: "spotify", serviceName: "Spotify", iconName: "music.note", category: .media),
        SubscriptionPreset(id: "apple_music", serviceName: "Apple Music", iconName: "apple.logo", category: .media),
        SubscriptionPreset(id: "youtube", serviceName: "YouTube Premium", iconName: "play.rectangle.fill", category: .media),
        SubscriptionPreset(id: "disney", serviceName: "Disney+", iconName: "film.fill", category: .media),
        SubscriptionPreset(id: "icloud", serviceName: "iCloud", iconName: "cloud.fill", category: .utilities),
        SubscriptionPreset(id: "adobe", serviceName: "Adobe Creative Cloud", iconName: "paintbrush.fill", category: .software),
        SubscriptionPreset(id: "office", serviceName: "Microsoft 365", iconName: "doc.fill", category: .software),
        SubscriptionPreset(id: "custom", serviceName: "Custom service", iconName: "plus.circle.fill", category: .other)
    ]

    static func preset(for id: String) -> SubscriptionPreset? {
        all.first { $0.id == id }
    }
}
