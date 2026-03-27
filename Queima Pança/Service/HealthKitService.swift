import Foundation
import HealthKit

// MARK: - HealthKit Service

final class HealthKitService {

    static let shared = HealthKitService()
    private let healthStore = HKHealthStore()
    private init() {}

    // MARK: - Availability

    var isAvailable: Bool {
        HKHealthStore.isHealthDataAvailable()
    }

    // MARK: - Authorization

    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        guard isAvailable else {
            completion(false)
            return
        }

        let typesToWrite: Set<HKSampleType> = [
            HKObjectType.workoutType(),
            HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!
        ]

        let typesToRead: Set<HKObjectType> = [
            HKObjectType.workoutType(),
            HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!,
            HKObjectType.quantityType(forIdentifier: .stepCount)!
        ]

        healthStore.requestAuthorization(toShare: typesToWrite, read: typesToRead) { success, error in
            DispatchQueue.main.async {
                if let error {
                    print("❌ HealthKit auth error: \(error.localizedDescription)")
                }
                completion(success)
            }
        }
    }

    // MARK: - Check Authorization Status

    func isAuthorized() -> Bool {
        guard isAvailable else { return false }
        let workoutType = HKObjectType.workoutType()
        return healthStore.authorizationStatus(for: workoutType) == .sharingAuthorized
    }

    // MARK: - Save Workout

    /// Save a completed workout to HealthKit
    func saveWorkout(
        name: String,
        duration: TimeInterval,
        caloriesBurned: Double,
        startDate: Date? = nil,
        completion: @escaping (Bool) -> Void
    ) {
        guard isAvailable else {
            completion(false)
            return
        }

        let end = Date()
        let start = startDate ?? end.addingTimeInterval(-duration)

        let workout = HKWorkout(
            activityType: .traditionalStrengthTraining,
            start: start,
            end: end,
            duration: duration,
            totalEnergyBurned: HKQuantity(unit: .kilocalorie(), doubleValue: caloriesBurned),
            totalDistance: nil,
            metadata: [
                HKMetadataKeyWorkoutBrandName: "Queima Pança",
                "WorkoutName": name
            ]
        )

        healthStore.save(workout) { success, error in
            DispatchQueue.main.async {
                if let error {
                    print("❌ HealthKit save error: \(error.localizedDescription)")
                }
                completion(success)
            }
        }
    }

    // MARK: - Save Active Calories

    func saveActiveCalories(
        calories: Double,
        start: Date,
        end: Date,
        completion: @escaping (Bool) -> Void
    ) {
        guard isAvailable,
              let calorieType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned) else {
            completion(false)
            return
        }

        let quantity = HKQuantity(unit: .kilocalorie(), doubleValue: calories)
        let sample = HKQuantitySample(
            type: calorieType,
            quantity: quantity,
            start: start,
            end: end
        )

        healthStore.save(sample) { success, error in
            DispatchQueue.main.async {
                if let error {
                    print("❌ HealthKit calories save error: \(error.localizedDescription)")
                }
                completion(success)
            }
        }
    }

    // MARK: - Read Today's Steps

    func fetchTodaySteps(completion: @escaping (Double) -> Void) {
        guard isAvailable,
              let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount) else {
            completion(0)
            return
        }

        let startOfDay = Calendar.current.startOfDay(for: Date())
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: Date(), options: .strictStartDate)

        let query = HKStatisticsQuery(
            quantityType: stepType,
            quantitySamplePredicate: predicate,
            options: .cumulativeSum
        ) { _, result, error in
            DispatchQueue.main.async {
                guard let result = result, let sum = result.sumQuantity() else {
                    completion(0)
                    return
                }
                completion(sum.doubleValue(for: .count()))
            }
        }

        healthStore.execute(query)
    }

    // MARK: - Read Today's Calories

    func fetchTodayCalories(completion: @escaping (Double) -> Void) {
        guard isAvailable,
              let calorieType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned) else {
            completion(0)
            return
        }

        let startOfDay = Calendar.current.startOfDay(for: Date())
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: Date(), options: .strictStartDate)

        let query = HKStatisticsQuery(
            quantityType: calorieType,
            quantitySamplePredicate: predicate,
            options: .cumulativeSum
        ) { _, result, error in
            DispatchQueue.main.async {
                guard let result = result, let sum = result.sumQuantity() else {
                    completion(0)
                    return
                }
                completion(sum.doubleValue(for: .kilocalorie()))
            }
        }

        healthStore.execute(query)
    }

    // MARK: - Estimate Calories

    /// Rough estimation: ~5 kcal/min for strength training
    static func estimateCalories(durationMinutes: Int, intensity: Double = 1.0) -> Double {
        Double(durationMinutes) * 5.0 * intensity
    }
}
