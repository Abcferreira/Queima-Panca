//
//  WorkoutViewModel.swift
//  Queima Pança
//
//  Created by Anderson Borges Costa Ferreira on 18/07/25.
//

import Foundation
import Combine

// MARK: - Workout ViewModel

final class WorkoutViewModel: ObservableObject {

    // MARK: - Published State
    @Published var workouts: [DayWorkout] = []
    @Published var completedSets: [UUID: [Bool]] = [:]
    @Published var completedWorkouts: Set<UUID> = []

    // MARK: - Sub ViewModels
    let restTimerVM = RestTimerViewModel()

    // MARK: - Dependencies
    private let repository: WorkoutRepositoryProtocol

    // MARK: - Init

    init(repository: WorkoutRepositoryProtocol = LocalWorkoutRepository()) {
        self.repository = repository
        loadWorkouts()
    }

    // MARK: - Data Loading

    func loadWorkouts() {
        workouts = repository.fetchWorkouts()
    }

    // MARK: - Set Tracking

    func toggleSet(for exerciseID: UUID, index: Int, totalSets: Int) {
        if completedSets[exerciseID] == nil {
            completedSets[exerciseID] = Array(repeating: false, count: totalSets)
        }

        completedSets[exerciseID]?[index].toggle()

        // Start rest timer when marking a set as completed
        if completedSets[exerciseID]?[index] == true {
            restTimerVM.start(duration: 60)
        }
    }

    func isSetCompleted(for exerciseID: UUID, index: Int) -> Bool {
        completedSets[exerciseID]?[index] ?? false
    }

    func completedSetsCount(for exerciseID: UUID) -> Int {
        completedSets[exerciseID]?.filter { $0 }.count ?? 0
    }

    // MARK: - Workout Progress

    func workoutProgress(for workout: DayWorkout) -> Double {
        let total = workout.totalSets
        guard total > 0 else { return 0 }
        let completed = workout.exercises.reduce(0) { sum, ex in
            sum + completedSetsCount(for: ex.id)
        }
        return Double(completed) / Double(total)
    }

    func isWorkoutCompleted(_ workout: DayWorkout) -> Bool {
        completedWorkouts.contains(workout.id)
    }

    func markWorkoutCompleted(_ workout: DayWorkout) {
        completedWorkouts.insert(workout.id)
    }

    func toggleWorkoutCompletion(_ workout: DayWorkout) {
        if completedWorkouts.contains(workout.id) {
            completedWorkouts.remove(workout.id)
        } else {
            completedWorkouts.insert(workout.id)
        }
    }

    // MARK: - Overall Stats

    var totalWorkoutsCompleted: Int {
        completedWorkouts.count
    }

    var weeklyProgressPercent: Double {
        guard !workouts.isEmpty else { return 0 }
        let total = workouts.reduce(0.0) { $0 + workoutProgress(for: $1) }
        return total / Double(workouts.count)
    }

    // MARK: - Reset

    func resetProgress() {
        completedSets.removeAll()
        completedWorkouts.removeAll()
    }
}
