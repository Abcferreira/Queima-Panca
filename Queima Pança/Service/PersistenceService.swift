import Foundation
import SwiftData

// MARK: - Persistence Service

final class PersistenceService {

    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    // MARK: - Exercise Progress

    /// Load completed sets for all exercises as [exerciseID: [Bool]]
    func loadCompletedSets(for exercises: [Exercise]) -> [UUID: [Bool]] {
        var result: [UUID: [Bool]] = [:]

        for exercise in exercises {
            let exerciseID = exercise.id
            let predicate = #Predicate<ExerciseProgress> {
                $0.exerciseID == exerciseID
            }
            let descriptor = FetchDescriptor<ExerciseProgress>(predicate: predicate)

            guard let records = try? modelContext.fetch(descriptor) else { continue }

            if !records.isEmpty {
                var sets = Array(repeating: false, count: exercise.setsCount)
                for record in records where record.setIndex < exercise.setsCount {
                    sets[record.setIndex] = record.isCompleted
                }
                result[exerciseID] = sets
            }
        }

        return result
    }

    /// Save or update a single set completion
    func toggleSet(exerciseID: UUID, setIndex: Int, isCompleted: Bool) {
        let predicate = #Predicate<ExerciseProgress> {
            $0.exerciseID == exerciseID && $0.setIndex == setIndex
        }
        let descriptor = FetchDescriptor<ExerciseProgress>(predicate: predicate)

        if let existing = try? modelContext.fetch(descriptor).first {
            existing.isCompleted = isCompleted
            existing.completedAt = isCompleted ? Date() : nil
        } else {
            let progress = ExerciseProgress(exerciseID: exerciseID, setIndex: setIndex, isCompleted: isCompleted)
            modelContext.insert(progress)
        }

        save()
    }

    // MARK: - Workout Progress

    /// Load all completed workout IDs
    func loadCompletedWorkouts() -> Set<UUID> {
        let predicate = #Predicate<WorkoutProgress> {
            $0.isCompleted == true
        }
        let descriptor = FetchDescriptor<WorkoutProgress>(predicate: predicate)

        guard let records = try? modelContext.fetch(descriptor) else { return [] }
        return Set(records.map(\.workoutID))
    }

    /// Toggle workout completion state
    func toggleWorkoutCompletion(workoutID: UUID, isCompleted: Bool) {
        let predicate = #Predicate<WorkoutProgress> {
            $0.workoutID == workoutID
        }
        let descriptor = FetchDescriptor<WorkoutProgress>(predicate: predicate)

        if let existing = try? modelContext.fetch(descriptor).first {
            existing.isCompleted = isCompleted
            existing.completedAt = isCompleted ? Date() : nil
        } else {
            let progress = WorkoutProgress(workoutID: workoutID, isCompleted: isCompleted)
            modelContext.insert(progress)
        }

        save()
    }

    // MARK: - History

    /// Save a workout to history
    func saveToHistory(workoutID: UUID, workoutDay: String, totalSets: Int, completedSets: Int) {
        let entry = WorkoutHistory(
            workoutID: workoutID,
            workoutDay: workoutDay,
            totalSets: totalSets,
            completedSets: completedSets
        )
        modelContext.insert(entry)
        save()
    }

    /// Fetch workout history sorted by date
    func fetchHistory() -> [WorkoutHistory] {
        let descriptor = FetchDescriptor<WorkoutHistory>(
            sortBy: [SortDescriptor(\.completedAt, order: .reverse)]
        )
        return (try? modelContext.fetch(descriptor)) ?? []
    }

    // MARK: - Reset

    /// Clear all progress (for starting a new week)
    func resetAllProgress() {
        do {
            try modelContext.delete(model: ExerciseProgress.self)
            try modelContext.delete(model: WorkoutProgress.self)
            save()
        } catch {
            print("❌ Error resetting progress: \(error)")
        }
    }

    // MARK: - Private

    private func save() {
        do {
            try modelContext.save()
        } catch {
            print("❌ SwiftData save error: \(error)")
        }
    }
}
