//
//  ContentView.swift
//  Queima Pança
//
//  Created by Anderson Borges Costa Ferreira on 18/07/25.
//

import SwiftUI

// MARK: - Home View

struct ContentView: View {
    @EnvironmentObject var viewModel: WorkoutViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {

                    // MARK: - Header
                    headerSection

                    // MARK: - Weekly Progress
                    weeklyProgressSection

                    // MARK: - Workout List
                    workoutListSection
                }
                .padding(.horizontal)
                .padding(.bottom, 32)
            }
            .background(AppTheme.background.ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    HStack(spacing: 6) {
                        Image(systemName: "flame.fill")
                            .foregroundColor(.orange)
                        Text("Queima Pança")
                            .font(.headline)
                    }
                }
            }
        }
    }

    // MARK: - Header Section

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(greeting)
                .font(.title2.bold())

            Text("Seu plano semanal está pronto. Bora treinar! 💪")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, 8)
    }

    // MARK: - Weekly Progress

    private var weeklyProgressSection: some View {
        HStack(spacing: 16) {
            ProgressRing(
                progress: viewModel.weeklyProgressPercent,
                size: 72,
                lineWidth: 7
            )

            VStack(alignment: .leading, spacing: 6) {
                Text("Progresso Semanal")
                    .font(.headline)

                HStack(spacing: 16) {
                    statItem(
                        value: "\(viewModel.totalWorkoutsCompleted)/\(viewModel.workouts.count)",
                        label: "Treinos"
                    )
                    statItem(
                        value: "\(totalExercisesDone)",
                        label: "Séries feitas"
                    )
                }
            }

            Spacer()
        }
        .fitnessCard()
    }

    // MARK: - Workout List

    private var workoutListSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Treinos da Semana")
                .font(.title3.bold())
                .padding(.leading, 4)

            ForEach(viewModel.workouts) { workout in
                NavigationLink(destination: WorkoutDetailView(dayWorkout: workout)) {
                    WorkoutCard(
                        workout: workout,
                        progress: viewModel.workoutProgress(for: workout),
                        isCompleted: viewModel.isWorkoutCompleted(workout)
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }

    // MARK: - Custom Workouts Section

    private var customWorkoutsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Treinos Customizados")
                .font(.title3.bold())
                .padding(.leading, 4)

            ForEach(viewModel.customWorkouts) { workout in
                NavigationLink(destination: WorkoutDetailView(dayWorkout: workout)) {
                    WorkoutCard(
                        workout: workout,
                        progress: viewModel.workoutProgress(for: workout),
                        isCompleted: viewModel.isWorkoutCompleted(workout)
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }

    // MARK: - Helpers

    private func statItem(value: String, label: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(value)
                .font(.subheadline.bold())
                .foregroundColor(AppTheme.primary)
            Text(label)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
    }

    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12: return "Bom dia! ☀️"
        case 12..<18: return "Boa tarde! 🌤️"
        default: return "Boa noite! 🌙"
        }
    }

    private var totalExercisesDone: Int {
        viewModel.workouts.reduce(0) { total, workout in
            total + workout.exercises.reduce(0) { sum, ex in
                sum + viewModel.completedSetsCount(for: ex.id)
            }
        }
    }
}
