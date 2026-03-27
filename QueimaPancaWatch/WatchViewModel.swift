import Foundation
import WatchConnectivity

// MARK: - Watch ViewModel

final class WatchViewModel: NSObject, ObservableObject {

    @Published var workouts: [WatchWorkout] = []
    @Published var isConnected = false

    // Timer
    @Published var timerRunning = false
    @Published var timerRemaining: Int = 60
    @Published var timerTotal: Int = 60
    private var timer: Timer?

    override init() {
        super.init()
        activateSession()
        loadSampleData()
    }

    // MARK: - WatchConnectivity

    private func activateSession() {
        guard WCSession.isSupported() else { return }
        let session = WCSession.default
        session.delegate = self
        session.activate()
    }

    // MARK: - Timer

    func startTimer(duration: Int = 60) {
        timerTotal = duration
        timerRemaining = duration
        timerRunning = true

        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self else { return }
            if self.timerRemaining > 0 {
                self.timerRemaining -= 1
            } else {
                self.stopTimer()
                WKInterfaceDevice.current().play(.success)
            }
        }
    }

    func stopTimer() {
        timer?.invalidate()
        timer = nil
        timerRunning = false
    }

    func addTime(_ seconds: Int) {
        timerRemaining += seconds
        timerTotal += seconds
    }

    var timerProgress: Double {
        guard timerTotal > 0 else { return 0 }
        return Double(timerTotal - timerRemaining) / Double(timerTotal)
    }

    // MARK: - Toggle Set

    func toggleSet(workoutIndex: Int, exerciseIndex: Int, setIndex: Int) {
        guard workoutIndex < workouts.count,
              exerciseIndex < workouts[workoutIndex].exercises.count,
              setIndex < workouts[workoutIndex].exercises[exerciseIndex].completedSets.count else { return }

        workouts[workoutIndex].exercises[exerciseIndex].completedSets[setIndex].toggle()
        let isCompleted = workouts[workoutIndex].exercises[exerciseIndex].completedSets[setIndex]

        // Send to iPhone
        if WCSession.default.isReachable {
            let exerciseID = workouts[workoutIndex].exercises[exerciseIndex].id
            let message: [String: Any] = [
                "type": "setToggle",
                "exerciseID": exerciseID,
                "setIndex": setIndex,
                "isCompleted": isCompleted
            ]
            WCSession.default.sendMessage(message, replyHandler: nil)
        }

        // Start rest timer
        if isCompleted {
            startTimer(duration: 60)
        }
    }

    // MARK: - Sample Data

    private func loadSampleData() {
        // Default data until iPhone syncs
        workouts = [
            WatchWorkout(day: "Segunda", subtitle: "Full Body", icon: "figure.mixed.cardio", exercises: [
                WatchExercise(id: "seg-1", name: "Agachamento", setsCount: 4, reps: "10", completedSets: [false, false, false, false]),
                WatchExercise(id: "seg-2", name: "Supino", setsCount: 4, reps: "10", completedSets: [false, false, false, false]),
                WatchExercise(id: "seg-3", name: "Remada", setsCount: 3, reps: "12", completedSets: [false, false, false]),
            ]),
            WatchWorkout(day: "Terça", subtitle: "Cardio + Abdômen", icon: "figure.run", exercises: [
                WatchExercise(id: "ter-1", name: "Prancha", setsCount: 3, reps: "40s", completedSets: [false, false, false]),
                WatchExercise(id: "ter-2", name: "Elevação de pernas", setsCount: 3, reps: "15", completedSets: [false, false, false]),
            ]),
            WatchWorkout(day: "Quarta", subtitle: "Costas + Bíceps", icon: "figure.rower", exercises: [
                WatchExercise(id: "qua-1", name: "Puxada frente", setsCount: 4, reps: "10", completedSets: [false, false, false, false]),
                WatchExercise(id: "qua-2", name: "Rosca direta", setsCount: 3, reps: "12", completedSets: [false, false, false]),
            ]),
            WatchWorkout(day: "Quinta", subtitle: "Pernas + Glúteos", icon: "figure.walk", exercises: [
                WatchExercise(id: "qui-1", name: "Leg press", setsCount: 4, reps: "12", completedSets: [false, false, false, false]),
                WatchExercise(id: "qui-2", name: "Stiff", setsCount: 3, reps: "12", completedSets: [false, false, false]),
            ]),
            WatchWorkout(day: "Sexta", subtitle: "Peito + Ombro + Tríceps", icon: "figure.strengthtraining.traditional", exercises: [
                WatchExercise(id: "sex-1", name: "Supino inclinado", setsCount: 4, reps: "10", completedSets: [false, false, false, false]),
                WatchExercise(id: "sex-2", name: "Elevação lateral", setsCount: 3, reps: "12", completedSets: [false, false, false]),
            ])
        ]
    }
}

// MARK: - WCSessionDelegate

extension WatchViewModel: WCSessionDelegate {

    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        DispatchQueue.main.async {
            self.isConnected = activationState == .activated
        }
    }

    func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
        DispatchQueue.main.async {
            self.handleMessage(message)
        }
    }

    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String: Any]) {
        DispatchQueue.main.async {
            self.handleMessage(applicationContext)
        }
    }

    private func handleMessage(_ message: [String: Any]) {
        guard let type = message["type"] as? String else { return }

        switch type {
        case "workoutSync":
            if let workoutsData = message["workouts"] as? [[String: Any]] {
                parseWorkouts(workoutsData)
            }
        default:
            break
        }
    }

    private func parseWorkouts(_ data: [[String: Any]]) {
        workouts = data.compactMap { dict in
            guard let day = dict["day"] as? String,
                  let subtitle = dict["subtitle"] as? String,
                  let icon = dict["icon"] as? String,
                  let exercisesData = dict["exercises"] as? [[String: Any]] else { return nil }

            let exercises = exercisesData.compactMap { exDict -> WatchExercise? in
                guard let id = exDict["id"] as? String,
                      let name = exDict["name"] as? String,
                      let setsCount = exDict["setsCount"] as? Int,
                      let reps = exDict["repsOrDuration"] as? String,
                      let completedSets = exDict["completedSets"] as? [Bool] else { return nil }
                return WatchExercise(id: id, name: name, setsCount: setsCount, reps: reps, completedSets: completedSets)
            }

            return WatchWorkout(day: day, subtitle: subtitle, icon: icon, exercises: exercises)
        }
    }
}

// MARK: - Watch Models

struct WatchWorkout: Identifiable {
    let id = UUID()
    let day: String
    let subtitle: String
    let icon: String
    var exercises: [WatchExercise]

    var completedCount: Int {
        exercises.reduce(0) { $0 + $1.completedSets.filter { $0 }.count }
    }

    var totalSets: Int {
        exercises.reduce(0) { $0 + $1.setsCount }
    }

    var progress: Double {
        guard totalSets > 0 else { return 0 }
        return Double(completedCount) / Double(totalSets)
    }
}

struct WatchExercise: Identifiable {
    var id: String
    let name: String
    let setsCount: Int
    let reps: String
    var completedSets: [Bool]

    var completedCount: Int {
        completedSets.filter { $0 }.count
    }
}
