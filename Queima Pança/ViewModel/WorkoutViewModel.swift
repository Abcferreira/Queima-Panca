//
//  WorkoutViewModel.swift
//  Queima Pança
//
//  Created by Anderson Borges Costa Ferreira on 18/07/25.
//

import Foundation
import Combine
import SwiftData
import WidgetKit

// MARK: - Workout ViewModel

final class WorkoutViewModel: ObservableObject {

    // MARK: - Published State
    @Published var workouts: [DayWorkout] = []
    @Published var customWorkouts: [DayWorkout] = []
    @Published var completedSets: [UUID: [Bool]] = [:]
    @Published var completedWorkouts: Set<UUID> = []
    @Published var showRestTimer: Bool = false
    @Published var showAchievement: Bool = false
    @Published var lastCompletedWorkout: DayWorkout?

    /// All workouts (default + custom)
    var allWorkouts: [DayWorkout] {
        workouts + customWorkouts
    }

    // MARK: - Sub ViewModels
    let restTimerVM = RestTimerViewModel()

    // MARK: - Dependencies
    private let repository: WorkoutRepositoryProtocol
    private(set) var persistence: PersistenceService?
    private(set) var modelContext: ModelContext?

    // MARK: - Init

    init(repository: WorkoutRepositoryProtocol = LocalWorkoutRepository()) {
        self.repository = repository
        loadWorkouts()
    }

    /// Call this once the ModelContext is available (from the App)
    func configure(with modelContext: ModelContext) {
        self.modelContext = modelContext
        self.persistence = PersistenceService(modelContext: modelContext)
        loadProgress()
        loadCustomWorkouts()
        updateWidgetData()
    }

    // MARK: - Data Loading

    func loadWorkouts() {
        workouts = repository.fetchWorkouts()
    }

    /// Load custom workouts from SwiftData
    func loadCustomWorkouts() {
        guard let modelContext else { return }
        let descriptor = FetchDescriptor<CustomWorkout>(sortBy: [SortDescriptor(\.createdAt)])
        guard let customs = try? modelContext.fetch(descriptor) else { return }
        customWorkouts = customs.map { $0.toDayWorkout() }
    }

    /// Load persisted progress from SwiftData
    private func loadProgress() {
        guard let persistence else { return }

        let allExercises = allWorkouts.flatMap(\.exercises)
        completedSets = persistence.loadCompletedSets(for: allExercises)
        completedWorkouts = persistence.loadCompletedWorkouts()
    }

    // MARK: - Set Tracking

    func toggleSet(for exerciseID: UUID, index: Int, totalSets: Int) {
        if completedSets[exerciseID] == nil {
            completedSets[exerciseID] = Array(repeating: false, count: totalSets)
        }

        completedSets[exerciseID]?[index].toggle()
        let isCompleted = completedSets[exerciseID]?[index] ?? false

        // Persist
        persistence?.toggleSet(exerciseID: exerciseID, setIndex: index, isCompleted: isCompleted)

        // Start rest timer when marking a set as completed
        if isCompleted {
            restTimerVM.start(duration: 60)
            showRestTimer = true
        }

        updateWidgetData()
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
        persistence?.toggleWorkoutCompletion(workoutID: workout.id, isCompleted: true)

        // Save to history
        let completedSetsTotal = workout.exercises.reduce(0) { $0 + completedSetsCount(for: $1.id) }
        persistence?.saveToHistory(
            workoutID: workout.id,
            workoutDay: workout.day,
            totalSets: workout.totalSets,
            completedSets: completedSetsTotal
        )

        // Save to HealthKit
        saveToHealthKit(workout: workout)

        // Trigger achievement modal
        lastCompletedWorkout = workout
        showAchievement = true
        updateWidgetData()
    }

    /// Save workout to Apple Health
    private func saveToHealthKit(workout: DayWorkout) {
        guard HealthKitService.shared.isAuthorized() else { return }

        let duration = TimeInterval(workout.estimatedMinutes * 60)
        let calories = HealthKitService.estimateCalories(durationMinutes: workout.estimatedMinutes)

        HealthKitService.shared.saveWorkout(
            name: "\(workout.day) — \(workout.subtitle)",
            duration: duration,
            caloriesBurned: calories
        ) { success in
            if success {
                print("✅ Treino salvo no Apple Saúde")
            }
        }
    }
    func toggleWorkoutCompletion(_ workout: DayWorkout) {
        if completedWorkouts.contains(workout.id) {
            completedWorkouts.remove(workout.id)
            persistence?.toggleWorkoutCompletion(workoutID: workout.id, isCompleted: false)
            showAchievement = false
        } else {
            markWorkoutCompleted(workout)
        }
    }

    // MARK: - Weight Calculation

    /// Calculate total weight lifted for a workout based on sets completed × weight in notes
    func totalWeightLifted(for workout: DayWorkout) -> Double {
        workout.exercises.reduce(0.0) { total, exercise in
            let setsCompleted = completedSetsCount(for: exercise.id)
            let reps = Int(exercise.repsOrDuration.filter(\.isNumber)) ?? 0
            let weight = parseWeight(from: exercise.notes)
            return total + (Double(setsCompleted) * Double(reps) * weight)
        }
    }

    /// Parse weight from notes like "20.0kg" or "15kg"
    private func parseWeight(from notes: String) -> Double {
        let cleaned = notes
            .replacingOccurrences(of: "kg", with: "")
            .replacingOccurrences(of: " ", with: "")
        return Double(cleaned) ?? 0
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
        persistence?.resetAllProgress()
    }
}
