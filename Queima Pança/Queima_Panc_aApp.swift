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

    let modelContainer: ModelContainer = {
        let schema = Schema([
            ExerciseProgress.self,
            WorkoutProgress.self,
            WorkoutHistory.self,
            CustomWorkout.self,
            CustomExercise.self
        ])
        do {
            return try ModelContainer(for: schema)
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

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
            .modelContainer(modelContainer)
            .onAppear {
                let context = ModelContext(modelContainer)
                viewModel.configure(with: context)
            }
        }
    }
}
