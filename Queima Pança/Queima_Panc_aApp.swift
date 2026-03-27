//
//  Queima_Panc_aApp.swift
//  Queima Pança
//
//  Created by Anderson Borges Costa Ferreira on 18/07/25.
//

import SwiftUI
import SwiftData

@main
struct Queima_Panc_aApp: App {
    @StateObject private var viewModel = WorkoutViewModel()

    var body: some Scene {
        WindowGroup {
            TabView {
                ContentView()
                    .tabItem {
                        Label("Treinos", systemImage: "dumbbell")
                    }

                CustomWorkoutsView()
                    .tabItem {
                        Label("Meus Treinos", systemImage: "square.and.pencil")
                    }

                SettingsView()
                    .tabItem {
                        Label("Ajustes", systemImage: "gearshape")
                    }
            }
            .tint(AppTheme.primary)
            .environmentObject(viewModel)
            .modelContainer(for: [
                ExerciseProgress.self,
                WorkoutProgress.self,
                WorkoutHistory.self,
                CustomWorkout.self,
                CustomExercise.self
            ])
            .onAppear {
                if let container = try? ModelContainer(
                    for: ExerciseProgress.self,
                    WorkoutProgress.self,
                    WorkoutHistory.self,
                    CustomWorkout.self,
                    CustomExercise.self
                ) {
                    let context = ModelContext(container)
                    viewModel.configure(with: context)
                }
            }
        }
    }
}
