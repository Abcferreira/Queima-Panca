//
//  DayWorkout.swift
//  Queima Pança
//
//  Created by Anderson Borges Costa Ferreira on 18/07/25.
//

import Foundation

// MARK: - DayWorkout Model

struct DayWorkout: Identifiable, Hashable {
    let id: UUID
    let day: String
    let muscleGroups: [MuscleGroup]
    let exercises: [Exercise]
    let cardio: String
    let estimatedMinutes: Int

    /// Short subtitle from muscle groups
    var subtitle: String {
        muscleGroups.map(\.rawValue).joined(separator: " · ")
    }

    /// Total number of sets across all exercises
    var totalSets: Int {
        exercises.reduce(0) { $0 + $1.setsCount }
    }

    /// Primary icon based on first muscle group
    var icon: String {
        muscleGroups.first?.icon ?? "figure.mixed.cardio"
    }

    init(
        id: UUID = UUID(),
        day: String,
        muscleGroups: [MuscleGroup],
        exercises: [Exercise],
        cardio: String,
        estimatedMinutes: Int = 60
    ) {
        self.id = id
        self.day = day
        self.muscleGroups = muscleGroups
        self.exercises = exercises
        self.cardio = cardio
        self.estimatedMinutes = estimatedMinutes
    }

    // MARK: - Hashable
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: DayWorkout, rhs: DayWorkout) -> Bool {
        lhs.id == rhs.id
    }
}
