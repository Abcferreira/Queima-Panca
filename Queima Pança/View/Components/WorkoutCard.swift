import SwiftUI

// MARK: - Workout Card Component

struct WorkoutCard: View {
    let workout: DayWorkout
    let progress: Double
    let isCompleted: Bool

    var body: some View {
        HStack(spacing: 14) {
            // Icon
            ZStack {
                Circle()
                    .fill(isCompleted ? Color.green.opacity(0.15) : AppTheme.secondary)
                    .frame(width: 52, height: 52)

                Image(systemName: isCompleted ? "checkmark.circle.fill" : workout.icon)
                    .font(.title3)
                    .foregroundColor(isCompleted ? .green : AppTheme.primary)
            }

            // Info
            VStack(alignment: .leading, spacing: 4) {
                Text(workout.day)
                    .font(.headline)
                    .foregroundColor(.primary)
                    .lineLimit(1)

                Text(workout.subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)

                HStack(spacing: 12) {
                    Label("\(workout.exercises.count) exercícios", systemImage: "dumbbell")
                    Label("\(workout.estimatedMinutes) min", systemImage: "clock")
                }
                .font(.caption2)
                .foregroundColor(.secondary)
            }

            Spacer()

            // Progress ring
            ProgressRing(progress: progress, size: 44, lineWidth: 4)
        }
        .fitnessCard()
    }
}
