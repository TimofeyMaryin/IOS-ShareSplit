import Foundation

/// Category for analytics (Media, Software, Utilities)
enum SubscriptionCategory: String, Codable, CaseIterable {
    case media = "Media"
    case software = "Software"
    case utilities = "Utilities"
    case other = "Other"

    var displayName: String { rawValue }
}
