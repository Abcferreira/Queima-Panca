import SwiftUI

// MARK: - Workout Detail View

struct WorkoutDetailView: View {
    let dayWorkout: DayWorkout
    @EnvironmentObject var viewModel: WorkoutViewModel
    @Environment(\.openURL) private var openURL

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {

                // MARK: - Workout Header
                workoutHeader

                // MARK: - Exercises
                ForEach(dayWorkout.exercises) { exercise in
                    ExerciseCard(
                        exercise: exercise,
                        completedSetsCount: viewModel.completedSetsCount(for: exercise.id),
                        onToggleSet: { index in
                            viewModel.toggleSet(for: exercise.id, index: index, totalSets: exercise.setsCount)
                        },
                        onVideoTap: {
                            if let url = URL(string: exercise.videoURL) {
                                openURL(url)
                            }
                        }
                    )
                }

                // MARK: - Cardio Section
                cardioSection

                // MARK: - Complete Button
                completeWorkoutButton
            }
            .padding(.horizontal)
            .padding(.bottom, 32)
        }
        .background(AppTheme.background.ignoresSafeArea())
        .navigationTitle(dayWorkout.day)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $viewModel.showRestTimer) {
            RestTimerView(timerVM: viewModel.restTimerVM)
                .presentationDetents([.height(480)])
                .presentationDragIndicator(.visible)
        }
        .fullScreenCover(isPresented: $viewModel.showAchievement) {
            if let workout = viewModel.lastCompletedWorkout {
                WorkoutAchievementView(
                    workout: workout,
                    totalWeight: viewModel.totalWeightLifted(for: workout),
                    completedSets: workout.exercises.reduce(0) { $0 + viewModel.completedSetsCount(for: $1.id) },
                    totalSets: workout.totalSets
                )
            }
        }
    }

    // MARK: - Workout Header

    private var workoutHeader: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(AppTheme.secondary)
                        .frame(width: 48, height: 48)

                    Image(systemName: dayWorkout.icon)
                        .font(.title3)
                        .foregroundColor(AppTheme.primary)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(dayWorkout.subtitle)
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    HStack(spacing: 12) {
                        Label("\(dayWorkout.exercises.count) exercícios", systemImage: "dumbbell")
                        Label("~\(dayWorkout.estimatedMinutes) min", systemImage: "clock")
                    }
                    .font(.caption)
                    .foregroundColor(.secondary)
                }

                Spacer()

                ProgressRing(
                    progress: viewModel.workoutProgress(for: dayWorkout),
                    size: 52,
                    lineWidth: 5
                )
            }
        }
        .fitnessCard()
    }

    // MARK: - Cardio Section

    private var cardioSection: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color.red.opacity(0.12))
                    .frame(width: 44, height: 44)

                Image(systemName: "figure.run")
                    .font(.title3)
                    .foregroundColor(.red)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text("Cardio")
                    .font(.headline)
                Text(dayWorkout.cardio)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            Spacer()
        }
        .fitnessCard()
    }

    // MARK: - Complete Workout Button

    private var completeWorkoutButton: some View {
        Button(action: {
            viewModel.toggleWorkoutCompletion(dayWorkout)
        }) {
            HStack {
                Image(systemName: viewModel.isWorkoutCompleted(dayWorkout)
                      ? "checkmark.circle.fill"
                      : "circle")
                Text(viewModel.isWorkoutCompleted(dayWorkout)
                     ? "Treino Concluído ✅"
                     : "Marcar Treino como Concluído")
            }
            .primaryButton()
        }
        .padding(.top, 8)
    }
}
