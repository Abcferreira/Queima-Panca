import Foundation

// MARK: - Workout Repository Protocol

protocol WorkoutRepositoryProtocol {
    func fetchWorkouts() -> [DayWorkout]
}

// MARK: - Stable UUID Helper

/// Generates a deterministic UUID from a string seed (stable across launches)
private func stableUUID(_ seed: String) -> UUID {
    let hash = seed.utf8.reduce(0) { $0 &+ UInt64($1) &* 31 }
    let uuidString = String(format: "%08X-%04X-%04X-%04X-%012X",
                            UInt32(hash & 0xFFFFFFFF),
                            UInt16((hash >> 32) & 0xFFFF),
                            UInt16(0x4000 | ((hash >> 48) & 0x0FFF)),
                            UInt16(0x8000 | ((hash >> 56) & 0x3FFF)),
                            UInt64(hash &* 2654435761 & 0xFFFFFFFFFFFF))
    return UUID(uuidString: uuidString) ?? UUID()
}

// MARK: - Local Workout Repository

final class LocalWorkoutRepository: WorkoutRepositoryProtocol {

    func fetchWorkouts() -> [DayWorkout] {
        [
            makeSegunda(),
            makeTerca(),
            makeQuarta(),
            makeQuinta(),
            makeSexta()
        ]
    }

    // MARK: - Private Builders

    private func makeSegunda() -> DayWorkout {
        DayWorkout(
            id: stableUUID("workout-segunda"),
            day: "Segunda-feira",
            muscleGroups: [.fullBody],
            exercises: [
                Exercise(id: stableUUID("seg-agachamento"), name: "Agachamento livre ou Smith", muscleGroup: .legs, setsCount: 4, repsOrDuration: "10", videoURL: "https://www.youtube.com/watch?v=aclHkVaku9U"),
                Exercise(id: stableUUID("seg-supino"), name: "Supino reto com halteres", muscleGroup: .chest, setsCount: 4, repsOrDuration: "10", videoURL: "https://www.youtube.com/watch?v=VmB1G1K7v94"),
                Exercise(id: stableUUID("seg-remada"), name: "Remada curvada", muscleGroup: .back, setsCount: 3, repsOrDuration: "12", videoURL: "https://www.youtube.com/watch?v=vT2GjY_Umpw"),
                Exercise(id: stableUUID("seg-desenvolvimento"), name: "Desenvolvimento de ombro", muscleGroup: .shoulders, setsCount: 3, repsOrDuration: "12", videoURL: "https://www.youtube.com/watch?v=qEwKCR5JCog"),
                Exercise(id: stableUUID("seg-abdominal"), name: "Abdominal na polia ou solo", muscleGroup: .abs, setsCount: 3, repsOrDuration: "20", videoURL: "https://www.youtube.com/watch?v=1we3bh9uhqY")
            ],
            cardio: "20 min esteira (vel. 5, incl. 5%)",
            estimatedMinutes: 60
        )
    }

    private func makeTerca() -> DayWorkout {
        DayWorkout(
            id: stableUUID("workout-terca"),
            day: "Terça-feira",
            muscleGroups: [.cardio, .abs],
            exercises: [
                Exercise(id: stableUUID("ter-prancha"), name: "Prancha isométrica", muscleGroup: .abs, setsCount: 3, repsOrDuration: "40s", videoURL: "https://www.youtube.com/watch?v=pSHjTRCQxIw"),
                Exercise(id: stableUUID("ter-elevacao"), name: "Elevação de pernas na barra", muscleGroup: .abs, setsCount: 3, repsOrDuration: "15", videoURL: "https://www.youtube.com/watch?v=JB2oyawG9KI"),
                Exercise(id: stableUUID("ter-bicicleta"), name: "Bicicleta abdominal", muscleGroup: .abs, setsCount: 3, repsOrDuration: "20", videoURL: "https://www.youtube.com/watch?v=9FGilxCbdz8"),
                Exercise(id: stableUUID("ter-infra"), name: "Abdominal infra com elevação", muscleGroup: .abs, setsCount: 3, repsOrDuration: "15", videoURL: "https://www.youtube.com/watch?v=JB2oyawG9KI")
            ],
            cardio: "30 min esteira (vel. 5, incl. 5%)",
            estimatedMinutes: 50
        )
    }

    private func makeQuarta() -> DayWorkout {
        DayWorkout(
            id: stableUUID("workout-quarta"),
            day: "Quarta-feira",
            muscleGroups: [.back, .biceps],
            exercises: [
                Exercise(id: stableUUID("qua-puxada"), name: "Puxada frente", muscleGroup: .back, setsCount: 4, repsOrDuration: "10", videoURL: "https://www.youtube.com/watch?v=CAwf7n6Luuc"),
                Exercise(id: stableUUID("qua-remada"), name: "Remada unilateral", muscleGroup: .back, setsCount: 3, repsOrDuration: "12", videoURL: "https://www.youtube.com/watch?v=pYcpY20QaE8"),
                Exercise(id: stableUUID("qua-pulldown"), name: "Pulldown no cross", muscleGroup: .back, setsCount: 3, repsOrDuration: "12", videoURL: "https://www.youtube.com/watch?v=AjCCGN2tU3Q"),
                Exercise(id: stableUUID("qua-rosca"), name: "Rosca direta", muscleGroup: .biceps, setsCount: 3, repsOrDuration: "12", videoURL: "https://www.youtube.com/watch?v=kwG2ipFRgfo"),
                Exercise(id: stableUUID("qua-prancha"), name: "Prancha com toque de ombro", muscleGroup: .abs, setsCount: 3, repsOrDuration: "30s", videoURL: "https://www.youtube.com/watch?v=ynUw0YsrmSg")
            ],
            cardio: "20 min escada ou esteira inclinada",
            estimatedMinutes: 55
        )
    }

    private func makeQuinta() -> DayWorkout {
        DayWorkout(
            id: stableUUID("workout-quinta"),
            day: "Quinta-feira",
            muscleGroups: [.legs, .glutes],
            exercises: [
                Exercise(id: stableUUID("qui-legpress"), name: "Leg press", muscleGroup: .legs, setsCount: 4, repsOrDuration: "12", videoURL: "https://www.youtube.com/watch?v=IZxyjW7MPJQ"),
                Exercise(id: stableUUID("qui-afundo"), name: "Afundo com halteres", muscleGroup: .legs, setsCount: 3, repsOrDuration: "10", videoURL: "https://www.youtube.com/watch?v=D7KaRcUTQeE"),
                Exercise(id: stableUUID("qui-stiff"), name: "Stiff com halteres", muscleGroup: .glutes, setsCount: 3, repsOrDuration: "12", videoURL: "https://www.youtube.com/watch?v=ytGaGIn3SjE"),
                Exercise(id: stableUUID("qui-glute"), name: "Glute bridge", muscleGroup: .glutes, setsCount: 3, repsOrDuration: "15", videoURL: "https://www.youtube.com/watch?v=9qo48CYN06w"),
                Exercise(id: stableUUID("qui-abdominal"), name: "Abdominal infra estendido", muscleGroup: .abs, setsCount: 3, repsOrDuration: "20", videoURL: "https://www.youtube.com/watch?v=JB2oyawG9KI")
            ],
            cardio: "15 min escada ou bike leve",
            estimatedMinutes: 55
        )
    }

    private func makeSexta() -> DayWorkout {
        DayWorkout(
            id: stableUUID("workout-sexta"),
            day: "Sexta-feira",
            muscleGroups: [.chest, .shoulders, .triceps],
            exercises: [
                Exercise(id: stableUUID("sex-supino"), name: "Supino inclinado", muscleGroup: .chest, setsCount: 4, repsOrDuration: "10", videoURL: "https://www.youtube.com/watch?v=8iPEnn-ltC8"),
                Exercise(id: stableUUID("sex-crossover"), name: "Crossover ou peck deck", muscleGroup: .chest, setsCount: 3, repsOrDuration: "12", videoURL: "https://www.youtube.com/watch?v=taI4XduLpTk"),
                Exercise(id: stableUUID("sex-lateral"), name: "Elevação lateral", muscleGroup: .shoulders, setsCount: 3, repsOrDuration: "12", videoURL: "https://www.youtube.com/watch?v=kDqklk1ZESo"),
                Exercise(id: stableUUID("sex-triceps"), name: "Tríceps testa", muscleGroup: .triceps, setsCount: 3, repsOrDuration: "12", videoURL: "https://www.youtube.com/watch?v=d_KZxkY_0cM"),
                Exercise(id: stableUUID("sex-prancha"), name: "Prancha lateral", muscleGroup: .abs, setsCount: 3, repsOrDuration: "30s/lado", videoURL: "https://www.youtube.com/watch?v=K2VljzCC16g")
            ],
            cardio: "20–30 min esteira (zona 2)",
            estimatedMinutes: 60
        )
    }
}
