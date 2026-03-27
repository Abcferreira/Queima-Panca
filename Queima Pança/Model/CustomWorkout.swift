import Foundation
import SwiftData

// MARK: - Custom Workout (SwiftData)

@Model
final class CustomWorkout {
    var name: String
    var day: String
    var cardio: String
    var estimatedMinutes: Int
    var createdAt: Date
    @Relationship(deleteRule: .cascade) var exercises: [CustomExercise]

    init(
        name: String,
        day: String,
        exercises: [CustomExercise] = [],
        cardio: String = "",
        estimatedMinutes: Int = 60
    ) {
        self.name = name
        self.day = day
        self.exercises = exercises
        self.cardio = cardio
        self.estimatedMinutes = estimatedMinutes
        self.createdAt = Date()
    }

    /// Convert to DayWorkout for use in the app
    func toDayWorkout() -> DayWorkout {
        let muscleGroups = Array(Set(exercises.map(\.muscleGroup))).sorted { $0.rawValue < $1.rawValue }
        let exerciseList = exercises.enumerated().map { index, ex in
            Exercise(
                id: ex.stableID,
                name: ex.name,
                muscleGroup: ex.muscleGroup,
                setsCount: ex.setsCount,
                repsOrDuration: ex.repsOrDuration,
                notes: ex.weight > 0 ? "\(String(format: "%.1f", ex.weight))kg" : "",
                videoURL: ex.videoURL
            )
        }

        return DayWorkout(
            id: stableID,
            day: name,
            muscleGroups: muscleGroups,
            exercises: exerciseList,
            cardio: cardio,
            estimatedMinutes: estimatedMinutes
        )
    }

    /// Stable UUID derived from name + creation date
    var stableID: UUID {
        let seed = "\(name)-\(createdAt.timeIntervalSince1970)"
        return UUID(uuidString: deterministicUUID(from: seed)) ?? UUID()
    }
}

// MARK: - Custom Exercise (SwiftData)

@Model
final class CustomExercise {
    var name: String
    var muscleGroupRaw: String
    var setsCount: Int
    var repsOrDuration: String
    var weight: Double
    var videoURL: String
    var order: Int

    var muscleGroup: MuscleGroup {
        MuscleGroup(rawValue: muscleGroupRaw) ?? .fullBody
    }

    init(
        name: String,
        muscleGroup: MuscleGroup,
        setsCount: Int = 3,
        repsOrDuration: String = "12",
        weight: Double = 0,
        videoURL: String = "",
        order: Int = 0
    ) {
        self.name = name
        self.muscleGroupRaw = muscleGroup.rawValue
        self.setsCount = setsCount
        self.repsOrDuration = repsOrDuration
        self.weight = weight
        self.videoURL = videoURL
        self.order = order
    }

    /// Stable UUID derived from name + order
    var stableID: UUID {
        let seed = "\(name)-order-\(order)"
        return UUID(uuidString: deterministicUUID(from: seed)) ?? UUID()
    }
}

// MARK: - Deterministic UUID Helper

private func deterministicUUID(from seed: String) -> String {
    let hash = seed.utf8.reduce(0) { $0 &+ UInt64($1) &* 31 }
    return String(format: "%08X-%04X-%04X-%04X-%012X",
                  UInt32(hash & 0xFFFFFFFF),
                  UInt16((hash >> 32) & 0xFFFF),
                  UInt16(0x4000 | ((hash >> 48) & 0x0FFF)),
                  UInt16(0x8000 | ((hash >> 56) & 0x3FFF)),
                  UInt64(hash &* 2654435761 & 0xFFFFFFFFFFFF))
}
