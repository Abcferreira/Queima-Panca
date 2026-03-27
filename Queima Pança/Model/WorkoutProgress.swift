import Foundation
import SwiftData

// MARK: - Workout Progress (SwiftData)

/// Persists the completion state of a single exercise set
@Model
final class ExerciseProgress {
    var exerciseID: UUID
    var setIndex: Int
    var isCompleted: Bool
    var completedAt: Date?

    init(exerciseID: UUID, setIndex: Int, isCompleted: Bool = false) {
        self.exerciseID = exerciseID
        self.setIndex = setIndex
        self.isCompleted = isCompleted
        self.completedAt = isCompleted ? Date() : nil
    }
}

/// Persists the completion state of a full workout day
@Model
final class WorkoutProgress {
    var workoutID: UUID
    var isCompleted: Bool
    var completedAt: Date?
    var weekStartDate: Date

    init(workoutID: UUID, isCompleted: Bool = false, weekStartDate: Date = Date.startOfCurrentWeek) {
        self.workoutID = workoutID
        self.isCompleted = isCompleted
        self.completedAt = isCompleted ? Date() : nil
        self.weekStartDate = weekStartDate
    }
}

/// Persists weekly workout history
@Model
final class WorkoutHistory {
    var workoutID: UUID
    var workoutDay: String
    var completedAt: Date
    var totalSets: Int
    var completedSets: Int

    init(workoutID: UUID, workoutDay: String, completedAt: Date = Date(), totalSets: Int, completedSets: Int) {
        self.workoutID = workoutID
        self.workoutDay = workoutDay
        self.completedAt = completedAt
        self.totalSets = totalSets
        self.completedSets = completedSets
    }
}

// MARK: - Date Helper

extension Date {
    /// Returns Monday of the current week
    static var startOfCurrentWeek: Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date())
        return calendar.date(from: components) ?? Date()
    }
}
