//
//  Queima_Panc_aApp.swift
//  Queima Pança
//
//  Created by Anderson Borges Costa Ferreira on 18/07/25.
//

import SwiftUI

@main
struct Queima_Panc_aApp: App {
    @StateObject private var viewModel = WorkoutViewModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(viewModel)
        }
    }
}
