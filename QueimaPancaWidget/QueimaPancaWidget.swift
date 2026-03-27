import WidgetKit
import SwiftUI

// MARK: - Widget Entry

struct WorkoutWidgetEntry: TimelineEntry {
    let date: Date
    let workoutDay: String
    let muscleGroups: String
    let exerciseCount: Int
    let estimatedMinutes: Int
    let todayProgress: Double
    let weeklyProgress: Double
    let completedWorkouts: Int
    let totalWorkouts: Int
    let isRestDay: Bool
}

// MARK: - Timeline Provider

struct WorkoutTimelineProvider: TimelineProvider {

    func placeholder(in context: Context) -> WorkoutWidgetEntry {
        WorkoutWidgetEntry(
            date: Date(),
            workoutDay: "Segunda-feira",
            muscleGroups: "Full Body",
            exerciseCount: 5,
            estimatedMinutes: 60,
            todayProgress: 0.6,
            weeklyProgress: 0.4,
            completedWorkouts: 2,
            totalWorkouts: 5,
            isRestDay: false
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (WorkoutWidgetEntry) -> Void) {
        completion(entryFromSharedData())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<WorkoutWidgetEntry>) -> Void) {
        let entry = entryFromSharedData()
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 30, to: Date())!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }

    private func entryFromSharedData() -> WorkoutWidgetEntry {
        if let data = SharedDataService.load() {
            let isRestDay = isWeekend()
            return WorkoutWidgetEntry(
                date: Date(),
                workoutDay: data.todayWorkoutDay,
                muscleGroups: data.todayMuscleGroups,
                exerciseCount: data.todayExerciseCount,
                estimatedMinutes: data.todayEstimatedMinutes,
                todayProgress: data.todayProgress,
                weeklyProgress: data.weeklyProgress,
                completedWorkouts: data.completedWorkouts,
                totalWorkouts: data.totalWorkouts,
                isRestDay: isRestDay
            )
        }

        return WorkoutWidgetEntry(
            date: Date(),
            workoutDay: todayWorkoutName(),
            muscleGroups: "Carregando...",
            exerciseCount: 0,
            estimatedMinutes: 0,
            todayProgress: 0,
            weeklyProgress: 0,
            completedWorkouts: 0,
            totalWorkouts: 5,
            isRestDay: isWeekend()
        )
    }

    private func todayWorkoutName() -> String {
        let weekday = Calendar.current.component(.weekday, from: Date())
        switch weekday {
        case 2: return "Segunda-feira"
        case 3: return "Terça-feira"
        case 4: return "Quarta-feira"
        case 5: return "Quinta-feira"
        case 6: return "Sexta-feira"
        default: return "Descanso"
        }
    }

    private func isWeekend() -> Bool {
        let weekday = Calendar.current.component(.weekday, from: Date())
        return weekday == 1 || weekday == 7
    }
}

// MARK: - Small Widget View

struct SmallWidgetView: View {
    let entry: WorkoutWidgetEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "flame.fill")
                    .foregroundColor(.orange)
                Text("Queima Pança")
                    .font(.caption2.bold())
            }

            Spacer()

            if entry.isRestDay {
                VStack(alignment: .leading, spacing: 4) {
                    Image(systemName: "bed.double.fill")
                        .font(.title2)
                        .foregroundColor(.blue)
                    Text("Dia de Descanso")
                        .font(.caption.bold())
                    Text("Recupere-se! 😴")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            } else {
                VStack(alignment: .leading, spacing: 4) {
                    Text(entry.muscleGroups)
                        .font(.caption.bold())
                        .lineLimit(1)

                    Text("\(entry.exerciseCount) exercícios")
                        .font(.caption2)
                        .foregroundColor(.secondary)

                    // Progress bar
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 3)
                                .fill(Color.gray.opacity(0.2))
                                .frame(height: 6)

                            RoundedRectangle(cornerRadius: 3)
                                .fill(
                                    LinearGradient(
                                        colors: [.orange, .red],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(width: geo.size.width * entry.todayProgress, height: 6)
                        }
                    }
                    .frame(height: 6)
                }
            }

            HStack {
                Text("\(entry.completedWorkouts)/\(entry.totalWorkouts)")
                    .font(.system(size: 10, weight: .bold, design: .rounded))
                Text("semana")
                    .font(.system(size: 9))
                    .foregroundColor(.secondary)
            }
        }
        .padding(12)
    }
}

// MARK: - Medium Widget View

struct MediumWidgetView: View {
    let entry: WorkoutWidgetEntry

    var body: some View {
        HStack(spacing: 16) {
            // Left: Today's workout
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Image(systemName: "flame.fill")
                        .foregroundColor(.orange)
                    Text("Queima Pança")
                        .font(.caption.bold())
                }

                Spacer()

                if entry.isRestDay {
                    HStack(spacing: 8) {
                        Image(systemName: "bed.double.fill")
                            .font(.title2)
                            .foregroundColor(.blue)
                        VStack(alignment: .leading) {
                            Text("Dia de Descanso")
                                .font(.subheadline.bold())
                            Text("Recupere-se! 😴")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                } else {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(entry.workoutDay)
                            .font(.subheadline.bold())

                        Text(entry.muscleGroups)
                            .font(.caption)
                            .foregroundColor(.secondary)

                        HStack(spacing: 8) {
                            Label("\(entry.exerciseCount)", systemImage: "dumbbell")
                            Label("~\(entry.estimatedMinutes)min", systemImage: "clock")
                        }
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    }
                }

                // Progress bar
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 3)
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 6)

                        RoundedRectangle(cornerRadius: 3)
                            .fill(
                                LinearGradient(
                                    colors: [.orange, .red],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: geo.size.width * entry.todayProgress, height: 6)
                    }
                }
                .frame(height: 6)
            }

            // Right: Weekly progress
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .stroke(Color.gray.opacity(0.2), lineWidth: 6)

                    Circle()
                        .trim(from: 0, to: entry.weeklyProgress)
                        .stroke(
                            LinearGradient(
                                colors: [.orange, .red],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            style: StrokeStyle(lineWidth: 6, lineCap: .round)
                        )
                        .rotationEffect(.degrees(-90))

                    VStack(spacing: 0) {
                        Text("\(Int(entry.weeklyProgress * 100))%")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                        Text("semana")
                            .font(.system(size: 8))
                            .foregroundColor(.secondary)
                    }
                }
                .frame(width: 60, height: 60)

                Text("\(entry.completedWorkouts)/\(entry.totalWorkouts) treinos")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding(14)
    }
}

// MARK: - Widget Configuration

struct QueimaPancaWidget: Widget {
    let kind = "QueimaPancaWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: WorkoutTimelineProvider()) { entry in
            WidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Queima Pança")
        .description("Acompanhe seu treino do dia e progresso semanal.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

// MARK: - Entry View (router)

struct WidgetEntryView: View {
    @Environment(\.widgetFamily) var family
    let entry: WorkoutWidgetEntry

    var body: some View {
        switch family {
        case .systemSmall:
            SmallWidgetView(entry: entry)
        case .systemMedium:
            MediumWidgetView(entry: entry)
        default:
            SmallWidgetView(entry: entry)
        }
    }
}

// MARK: - Widget Bundle

@main
struct QueimaPancaWidgetBundle: WidgetBundle {
    var body: some Widget {
        QueimaPancaWidget()
    }
}

// MARK: - Preview

#Preview(as: .systemSmall) {
    QueimaPancaWidget()
} timeline: {
    WorkoutWidgetEntry(
        date: Date(),
        workoutDay: "Segunda-feira",
        muscleGroups: "Full Body",
        exerciseCount: 5,
        estimatedMinutes: 60,
        todayProgress: 0.6,
        weeklyProgress: 0.4,
        completedWorkouts: 2,
        totalWorkouts: 5,
        isRestDay: false
    )
}

#Preview(as: .systemMedium) {
    QueimaPancaWidget()
} timeline: {
    WorkoutWidgetEntry(
        date: Date(),
        workoutDay: "Segunda-feira",
        muscleGroups: "Full Body",
        exerciseCount: 5,
        estimatedMinutes: 60,
        todayProgress: 0.6,
        weeklyProgress: 0.4,
        completedWorkouts: 2,
        totalWorkouts: 5,
        isRestDay: false
    )
}
