import SwiftUI
import Charts
import SwiftData

// MARK: - History View

struct HistoryView: View {
    @EnvironmentObject var viewModel: WorkoutViewModel
    @State private var history: [WorkoutHistory] = []
    @State private var selectedPeriod: HistoryPeriod = .week

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Period picker
                    periodPicker

                    if history.isEmpty {
                        emptyState
                    } else {
                        // Weekly consistency chart
                        consistencyChart

                        // Sets progress chart
                        setsChart

                        // History list
                        historyList
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 32)
            }
            .background(AppTheme.background.ignoresSafeArea())
            .navigationTitle("Histórico")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear { loadHistory() }
        }
    }

    // MARK: - Period Picker

    private var periodPicker: some View {
        Picker("Período", selection: $selectedPeriod) {
            ForEach(HistoryPeriod.allCases) { period in
                Text(period.label).tag(period)
            }
        }
        .pickerStyle(.segmented)
        .onChange(of: selectedPeriod) { _, _ in loadHistory() }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 16) {
            Spacer().frame(height: 40)

            Image(systemName: "chart.bar.doc.horizontal")
                .font(.system(size: 50))
                .foregroundColor(AppTheme.primary.opacity(0.3))

            Text("Nenhum treino registrado")
                .font(.title3.bold())

            Text("Complete treinos para ver\nsua evolução aqui")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)

            Spacer().frame(height: 40)
        }
    }

    // MARK: - Consistency Chart

    private var consistencyChart: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "flame.fill")
                    .foregroundColor(.orange)
                Text("Consistência")
                    .font(.headline)
            }

            Chart(weeklyConsistencyData) { item in
                BarMark(
                    x: .value("Dia", item.day),
                    y: .value("Treinos", item.count)
                )
                .foregroundStyle(
                    LinearGradient(
                        colors: [.orange, .red],
                        startPoint: .bottom,
                        endPoint: .top
                    )
                )
                .cornerRadius(6)
            }
            .frame(height: 160)
            .chartYAxis {
                AxisMarks(values: .automatic(desiredCount: 3))
            }

            HStack {
                Label("\(filteredHistory.count) treinos", systemImage: "checkmark.circle")
                    .font(.caption)
                    .foregroundColor(.secondary)

                Spacer()

                Label("Série: \(currentStreak) dias", systemImage: "flame")
                    .font(.caption)
                    .foregroundColor(.orange)
            }
        }
        .fitnessCard()
    }

    // MARK: - Sets Chart

    private var setsChart: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .foregroundColor(.blue)
                Text("Séries Completadas")
                    .font(.headline)
            }

            Chart(setsProgressData) { item in
                LineMark(
                    x: .value("Data", item.date),
                    y: .value("Séries", item.completedSets)
                )
                .foregroundStyle(Color.blue)
                .interpolationMethod(.catmullRom)

                AreaMark(
                    x: .value("Data", item.date),
                    y: .value("Séries", item.completedSets)
                )
                .foregroundStyle(
                    LinearGradient(
                        colors: [.blue.opacity(0.3), .blue.opacity(0.05)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .interpolationMethod(.catmullRom)

                PointMark(
                    x: .value("Data", item.date),
                    y: .value("Séries", item.completedSets)
                )
                .foregroundStyle(Color.blue)
                .symbolSize(30)
            }
            .frame(height: 160)
            .chartXAxis {
                AxisMarks(values: .stride(by: .day)) { value in
                    AxisValueLabel {
                        if let date = value.as(Date.self) {
                            Text(date, format: .dateTime.day().month(.abbreviated))
                                .font(.caption2)
                        }
                    }
                }
            }

            HStack {
                statsItem(
                    label: "Média/treino",
                    value: "\(averageSetsPerWorkout)"
                )
                Spacer()
                statsItem(
                    label: "Total de séries",
                    value: "\(totalCompletedSets)"
                )
                Spacer()
                statsItem(
                    label: "Aproveitamento",
                    value: "\(completionRate)%"
                )
            }
        }
        .fitnessCard()
    }

    // MARK: - History List

    private var historyList: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Detalhes")
                .font(.headline)
                .padding(.leading, 4)

            ForEach(filteredHistory, id: \.workoutID) { entry in
                HStack(spacing: 12) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(entry.workoutDay)
                            .font(.subheadline.bold())

                        Text(entry.completedAt, format: .dateTime.day().month().year().hour().minute())
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }

                    Spacer()

                    VStack(alignment: .trailing, spacing: 4) {
                        Text("\(entry.completedSets)/\(entry.totalSets)")
                            .font(.subheadline.bold())
                            .foregroundColor(AppTheme.primary)

                        Text("séries")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }

                    // Completion badge
                    let pct = entry.totalSets > 0 ? Double(entry.completedSets) / Double(entry.totalSets) : 0
                    Circle()
                        .fill(pct >= 0.8 ? Color.green : pct >= 0.5 ? Color.orange : Color.red)
                        .frame(width: 10, height: 10)
                }
                .fitnessCard()
            }
        }
    }

    // MARK: - Helpers

    private func statsItem(label: String, value: String) -> some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.subheadline.bold())
                .foregroundColor(AppTheme.primary)
            Text(label)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
    }

    private func loadHistory() {
        history = viewModel.persistence?.fetchHistory() ?? []
    }

    private var filteredHistory: [WorkoutHistory] {
        let cutoffDate: Date
        switch selectedPeriod {
        case .week:
            cutoffDate = Calendar.current.date(byAdding: .day, value: -7, to: Date())!
        case .month:
            cutoffDate = Calendar.current.date(byAdding: .month, value: -1, to: Date())!
        case .all:
            return history
        }
        return history.filter { $0.completedAt >= cutoffDate }
    }

    // MARK: - Chart Data

    private var weeklyConsistencyData: [ConsistencyItem] {
        let days = ["Seg", "Ter", "Qua", "Qui", "Sex", "Sáb", "Dom"]
        let dayMapping: [String: String] = [
            "Segunda-feira": "Seg",
            "Terça-feira": "Ter",
            "Quarta-feira": "Qua",
            "Quinta-feira": "Qui",
            "Sexta-feira": "Sex",
            "Sábado": "Sáb",
            "Domingo": "Dom"
        ]

        var counts: [String: Int] = [:]
        for day in days { counts[day] = 0 }

        for entry in filteredHistory {
            if let shortDay = dayMapping[entry.workoutDay] {
                counts[shortDay, default: 0] += 1
            }
        }

        return days.map { ConsistencyItem(day: $0, count: counts[$0] ?? 0) }
    }

    private var setsProgressData: [SetsProgressItem] {
        filteredHistory
            .sorted { $0.completedAt < $1.completedAt }
            .map { SetsProgressItem(date: $0.completedAt, completedSets: $0.completedSets, totalSets: $0.totalSets) }
    }

    private var currentStreak: Int {
        let calendar = Calendar.current
        var streak = 0
        var checkDate = Date()

        let dates = Set(history.map { calendar.startOfDay(for: $0.completedAt) })

        for _ in 0..<30 {
            let dayStart = calendar.startOfDay(for: checkDate)
            if dates.contains(dayStart) {
                streak += 1
            } else {
                break
            }
            checkDate = calendar.date(byAdding: .day, value: -1, to: checkDate)!
        }

        return streak
    }

    private var averageSetsPerWorkout: Int {
        guard !filteredHistory.isEmpty else { return 0 }
        let total = filteredHistory.reduce(0) { $0 + $1.completedSets }
        return total / filteredHistory.count
    }

    private var totalCompletedSets: Int {
        filteredHistory.reduce(0) { $0 + $1.completedSets }
    }

    private var completionRate: Int {
        guard !filteredHistory.isEmpty else { return 0 }
        let totalSets = filteredHistory.reduce(0) { $0 + $1.totalSets }
        let completed = filteredHistory.reduce(0) { $0 + $1.completedSets }
        guard totalSets > 0 else { return 0 }
        return Int((Double(completed) / Double(totalSets)) * 100)
    }
}

// MARK: - Chart Data Models

struct ConsistencyItem: Identifiable {
    let id = UUID()
    let day: String
    let count: Int
}

struct SetsProgressItem: Identifiable {
    let id = UUID()
    let date: Date
    let completedSets: Int
    let totalSets: Int
}

// MARK: - Period Enum

enum HistoryPeriod: String, CaseIterable, Identifiable {
    case week = "7 dias"
    case month = "30 dias"
    case all = "Tudo"

    var id: String { rawValue }
    var label: String { rawValue }
}
