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
            ContentView()
                .environmentObject(viewModel)
                .onAppear {
                    if let container = try? ModelContainer(
                        for: ExerciseProgress.self,
                        WorkoutProgress.self,
                        WorkoutHistory.self
                    ) {
                        let context = ModelContext(container)
                        viewModel.configure(with: context)
                    }
                }
        }
    }
}
