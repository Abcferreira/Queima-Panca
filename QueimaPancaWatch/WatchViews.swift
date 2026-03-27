import SwiftUI

// MARK: - Watch Home View

struct WatchHomeView: View {
    @EnvironmentObject var viewModel: WatchViewModel

    var body: some View {
        NavigationStack {
            List {
                ForEach(Array(viewModel.workouts.enumerated()), id: \.element.id) { workoutIndex, workout in
                    NavigationLink {
                        WatchWorkoutDetailView(workoutIndex: workoutIndex)
                    } label: {
                        HStack(spacing: 10) {
                            Image(systemName: workout.icon)
                                .foregroundColor(.orange)
                                .font(.body)
                                .frame(width: 24)

                            VStack(alignment: .leading, spacing: 2) {
                                Text(workout.day)
                                    .font(.caption.bold())

                                Text(workout.subtitle)
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                                    .lineLimit(1)
                            }

                            Spacer()

                            // Progress
                            ZStack {
                                Circle()
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 3)

                                Circle()
                                    .trim(from: 0, to: workout.progress)
                                    .stroke(Color.orange, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                                    .rotationEffect(.degrees(-90))

                                Text("\(Int(workout.progress * 100))%")
                                    .font(.system(size: 8, weight: .bold))
                            }
                            .frame(width: 28, height: 28)
                        }
                    }
                }

                // Timer shortcut
                NavigationLink {
                    WatchTimerView()
                } label: {
                    HStack {
                        Image(systemName: "timer")
                            .foregroundColor(.blue)
                        Text("Timer de Descanso")
                            .font(.caption)
                    }
                }
            }
            .navigationTitle("🔥 Queima")
        }
    }
}

// MARK: - Workout Detail View

struct WatchWorkoutDetailView: View {
    @EnvironmentObject var viewModel: WatchViewModel
    let workoutIndex: Int

    private var workout: WatchWorkout {
        viewModel.workouts[workoutIndex]
    }

    var body: some View {
        List {
            ForEach(Array(workout.exercises.enumerated()), id: \.element.id) { exerciseIndex, exercise in
                VStack(alignment: .leading, spacing: 6) {
                    Text(exercise.name)
                        .font(.caption.bold())
                        .lineLimit(2)

                    Text("\(exercise.setsCount)x\(exercise.reps)")
                        .font(.caption2)
                        .foregroundColor(.secondary)

                    // Set tracker
                    HStack(spacing: 6) {
                        ForEach(0..<exercise.setsCount, id: \.self) { setIndex in
                            Button {
                                viewModel.toggleSet(
                                    workoutIndex: workoutIndex,
                                    exerciseIndex: exerciseIndex,
                                    setIndex: setIndex
                                )
                            } label: {
                                Image(systemName: setIndex < exercise.completedCount
                                      ? "checkmark.circle.fill"
                                      : "circle")
                                    .foregroundColor(setIndex < exercise.completedCount ? .green : .gray)
                                    .font(.body)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .padding(.vertical, 2)
            }
        }
        .navigationTitle(workout.day)
    }
}

// MARK: - Timer View

struct WatchTimerView: View {
    @EnvironmentObject var viewModel: WatchViewModel

    var body: some View {
        VStack(spacing: 12) {
            // Timer ring
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.3), lineWidth: 6)

                Circle()
                    .trim(from: 0, to: viewModel.timerProgress)
                    .stroke(
                        LinearGradient(
                            colors: [.orange, .red],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(lineWidth: 6, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .animation(.linear(duration: 1), value: viewModel.timerProgress)

                VStack(spacing: 2) {
                    Text(timeString)
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .monospacedDigit()

                    if viewModel.timerRunning {
                        Text("Descansando")
                            .font(.system(size: 9))
                            .foregroundColor(.secondary)
                    }
                }
            }
            .frame(width: 110, height: 110)

            if viewModel.timerRunning {
                HStack(spacing: 12) {
                    Button { viewModel.addTime(15) } label: {
                        Text("+15s")
                            .font(.caption2.bold())
                    }
                    .buttonStyle(.bordered)

                    Button { viewModel.stopTimer() } label: {
                        Image(systemName: "stop.fill")
                    }
                    .buttonStyle(.bordered)
                    .tint(.red)

                    Button { viewModel.addTime(30) } label: {
                        Text("+30s")
                            .font(.caption2.bold())
                    }
                    .buttonStyle(.bordered)
                }
            } else {
                HStack(spacing: 8) {
                    Button { viewModel.startTimer(duration: 60) } label: {
                        Text("1min")
                            .font(.caption2.bold())
                    }
                    .buttonStyle(.bordered)
                    .tint(.orange)

                    Button { viewModel.startTimer(duration: 90) } label: {
                        Text("1:30")
                            .font(.caption2.bold())
                    }
                    .buttonStyle(.bordered)
                    .tint(.orange)

                    Button { viewModel.startTimer(duration: 120) } label: {
                        Text("2min")
                            .font(.caption2.bold())
                    }
                    .buttonStyle(.bordered)
                    .tint(.orange)
                }
            }
        }
        .navigationTitle("Timer")
    }

    private var timeString: String {
        let minutes = viewModel.timerRemaining / 60
        let seconds = viewModel.timerRemaining % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}
