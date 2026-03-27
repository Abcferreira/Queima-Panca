import Foundation
import WatchConnectivity

// MARK: - Watch Connectivity Service

/// Syncs workout data between iPhone and Apple Watch
final class WatchConnectivityService: NSObject, ObservableObject {

    static let shared = WatchConnectivityService()

    @Published var isReachable = false
    @Published var receivedWorkoutData: WatchWorkoutData?

    private override init() {
        super.init()
    }

    // MARK: - Activation

    func activate() {
        guard WCSession.isSupported() else { return }
        let session = WCSession.default
        session.delegate = self
        session.activate()
    }

    // MARK: - Send Data to Watch

    func sendWorkoutsToWatch(workouts: [DayWorkout], completedSets: [UUID: [Bool]], completedWorkouts: Set<UUID>) {
        guard WCSession.default.isReachable else { return }

        let watchData = workouts.map { workout -> [String: Any] in
            let exercises = workout.exercises.map { ex -> [String: Any] in
                let sets = completedSets[ex.id] ?? Array(repeating: false, count: ex.setsCount)
                return [
                    "id": ex.id.uuidString,
                    "name": ex.name,
                    "muscleGroup": ex.muscleGroup.rawValue,
                    "setsCount": ex.setsCount,
                    "repsOrDuration": ex.repsOrDuration,
                    "completedSets": sets
                ]
            }

            return [
                "id": workout.id.uuidString,
                "day": workout.day,
                "subtitle": workout.subtitle,
                "icon": workout.icon,
                "exercises": exercises,
                "cardio": workout.cardio,
                "estimatedMinutes": workout.estimatedMinutes,
                "isCompleted": completedWorkouts.contains(workout.id)
            ]
        }

        let message: [String: Any] = [
            "type": "workoutSync",
            "workouts": watchData,
            "timestamp": Date().timeIntervalSince1970
        ]

        WCSession.default.sendMessage(message, replyHandler: nil) { error in
            print("❌ Watch send error: \(error.localizedDescription)")
        }
    }

    // MARK: - Send Set Toggle to Watch

    func sendSetToggle(exerciseID: UUID, setIndex: Int, isCompleted: Bool) {
        guard WCSession.default.isReachable else {
            // Use application context as fallback
            updateApplicationContext(exerciseID: exerciseID, setIndex: setIndex, isCompleted: isCompleted)
            return
        }

        let message: [String: Any] = [
            "type": "setToggle",
            "exerciseID": exerciseID.uuidString,
            "setIndex": setIndex,
            "isCompleted": isCompleted
        ]

        WCSession.default.sendMessage(message, replyHandler: nil)
    }

    private func updateApplicationContext(exerciseID: UUID, setIndex: Int, isCompleted: Bool) {
        do {
            try WCSession.default.updateApplicationContext([
                "type": "setToggle",
                "exerciseID": exerciseID.uuidString,
                "setIndex": setIndex,
                "isCompleted": isCompleted,
                "timestamp": Date().timeIntervalSince1970
            ])
        } catch {
            print("❌ Context update error: \(error.localizedDescription)")
        }
    }
}

// MARK: - WCSessionDelegate

extension WatchConnectivityService: WCSessionDelegate {

    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        DispatchQueue.main.async {
            self.isReachable = session.isReachable
        }
    }

    #if os(iOS)
    func sessionDidBecomeInactive(_ session: WCSession) {}
    func sessionDidDeactivate(_ session: WCSession) {
        session.activate()
    }
    #endif

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

    func sessionReachabilityDidChange(_ session: WCSession) {
        DispatchQueue.main.async {
            self.isReachable = session.isReachable
        }
    }

    private func handleMessage(_ message: [String: Any]) {
        guard let type = message["type"] as? String else { return }

        switch type {
        case "setToggle":
            if let idString = message["exerciseID"] as? String,
               let exerciseID = UUID(uuidString: idString),
               let setIndex = message["setIndex"] as? Int,
               let isCompleted = message["isCompleted"] as? Bool {
                receivedWorkoutData = WatchWorkoutData(
                    exerciseID: exerciseID,
                    setIndex: setIndex,
                    isCompleted: isCompleted
                )
            }
        default:
            break
        }
    }
}

// MARK: - Watch Workout Data

struct WatchWorkoutData {
    let exerciseID: UUID
    let setIndex: Int
    let isCompleted: Bool
}
