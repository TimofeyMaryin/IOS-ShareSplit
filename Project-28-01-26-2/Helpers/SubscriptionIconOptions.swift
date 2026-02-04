import Foundation
import SwiftUI

struct SubscriptionIconOption: Identifiable {
    let id: String
    let iconName: String
    var displayName: String { Self.displayNames[id] ?? iconName.replacingOccurrences(of: ".", with: " ") }

    private static let displayNames: [String: String] = [
        "play.rectangle.fill": "Video",
        "music.note": "Music",
        "film.fill": "Film",
        "creditcard.fill": "Card",
        "cloud.fill": "Cloud",
        "paintbrush.fill": "Brush",
        "doc.fill": "Document",
        "apple.logo": "Apple",
        "gamecontroller.fill": "Games",
        "tv.fill": "TV",
        "headphones": "Headphones",
        "book.fill": "Book",
        "newspaper.fill": "News",
        "envelope.fill": "Mail",
        "globe": "Globe",
        "star.fill": "Star",
        "heart.fill": "Heart",
        "plus.circle.fill": "Plus"
    ]
}

enum SubscriptionIconOptions {
    static let all: [SubscriptionIconOption] = [
        SubscriptionIconOption(id: "play.rectangle.fill", iconName: "play.rectangle.fill"),
        SubscriptionIconOption(id: "music.note", iconName: "music.note"),
        SubscriptionIconOption(id: "film.fill", iconName: "film.fill"),
        SubscriptionIconOption(id: "creditcard.fill", iconName: "creditcard.fill"),
        SubscriptionIconOption(id: "cloud.fill", iconName: "cloud.fill"),
        SubscriptionIconOption(id: "paintbrush.fill", iconName: "paintbrush.fill"),
        SubscriptionIconOption(id: "doc.fill", iconName: "doc.fill"),
        SubscriptionIconOption(id: "apple.logo", iconName: "apple.logo"),
        SubscriptionIconOption(id: "gamecontroller.fill", iconName: "gamecontroller.fill"),
        SubscriptionIconOption(id: "tv.fill", iconName: "tv.fill"),
        SubscriptionIconOption(id: "headphones", iconName: "headphones"),
        SubscriptionIconOption(id: "book.fill", iconName: "book.fill"),
        SubscriptionIconOption(id: "newspaper.fill", iconName: "newspaper.fill"),
        SubscriptionIconOption(id: "envelope.fill", iconName: "envelope.fill"),
        SubscriptionIconOption(id: "globe", iconName: "globe"),
        SubscriptionIconOption(id: "star.fill", iconName: "star.fill"),
        SubscriptionIconOption(id: "heart.fill", iconName: "heart.fill"),
        SubscriptionIconOption(id: "plus.circle.fill", iconName: "plus.circle.fill"),
    ]
}
