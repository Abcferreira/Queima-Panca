import Foundation

// MARK: - Shared Data (App Group)

/// Data shared between main app and widget via App Group UserDefaults
struct SharedWorkoutData: Codable {
    let todayWorkoutDay: String
    let todayMuscleGroups: String
    let todayExerciseCount: Int
    let todayEstimatedMinutes: Int
    let todayProgress: Double
    let weeklyProgress: Double
    let completedWorkouts: Int
    let totalWorkouts: Int
    let lastUpdated: Date
}

enum SharedDataService {
    static let appGroupID = "group.com.queimapanca.shared"

    static var sharedDefaults: UserDefaults? {
        UserDefaults(suiteName: appGroupID)
    }

    static func save(_ data: SharedWorkoutData) {
        guard let defaults = sharedDefaults,
              let encoded = try? JSONEncoder().encode(data) else { return }
        defaults.set(encoded, forKey: "widgetData")
    }

    static func load() -> SharedWorkoutData? {
        guard let defaults = sharedDefaults,
              let data = defaults.data(forKey: "widgetData"),
              let decoded = try? JSONDecoder().decode(SharedWorkoutData.self, from: data) else { return nil }
        return decoded
    }
}
