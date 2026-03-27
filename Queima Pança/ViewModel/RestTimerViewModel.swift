//
//  RestTimerViewModel.swift
//  Queima Pança
//
//  Created by Anderson Borges Costa Ferreira on 18/07/25.
//

import Foundation
import Combine
import SwiftUI

// MARK: - Rest Timer ViewModel

final class RestTimerViewModel: ObservableObject {

    // MARK: - Published State
    @Published var timeRemaining: Int = 60
    @Published var isRunning: Bool = false
    @Published var isPresented: Bool = false

    // MARK: - Configuration
    var totalDuration: Int = 60

    // MARK: - Computed
    var progress: Double {
        guard totalDuration > 0 else { return 0 }
        return Double(totalDuration - timeRemaining) / Double(totalDuration)
    }

    var timeFormatted: String {
        let minutes = timeRemaining / 60
        let seconds = timeRemaining % 60
        return String(format: "%01d:%02d", minutes, seconds)
    }

    // MARK: - Private
    private var timerCancellable: AnyCancellable?

    // MARK: - Actions

    func start(duration: Int = 60) {
        totalDuration = duration
        timeRemaining = duration
        isRunning = true
        isPresented = true

        timerCancellable = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.tick()
            }
    }

    func stop() {
        timerCancellable?.cancel()
        timerCancellable = nil
        isRunning = false
    }

    func dismiss() {
        stop()
        isPresented = false
        timeRemaining = totalDuration
    }

    func addTime(_ seconds: Int) {
        timeRemaining += seconds
        totalDuration += seconds
    }

    // MARK: - Private

    private func tick() {
        guard isRunning else { return }
        if timeRemaining > 0 {
            timeRemaining -= 1
        } else {
            stop()
            triggerHaptic()
        }
    }

    private func triggerHaptic() {
        #if os(iOS)
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        #endif
    }
}

