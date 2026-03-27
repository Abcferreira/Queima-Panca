import Foundation

// MARK: - Workout Repository Protocol

protocol WorkoutRepositoryProtocol {
    func fetchWorkouts() -> [DayWorkout]
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
            day: "Segunda-feira",
            muscleGroups: [.fullBody],
            exercises: [
                Exercise(name: "Agachamento livre ou Smith", muscleGroup: .legs, setsCount: 4, repsOrDuration: "10", videoURL: "https://www.youtube.com/watch?v=aclHkVaku9U"),
                Exercise(name: "Supino reto com halteres", muscleGroup: .chest, setsCount: 4, repsOrDuration: "10", videoURL: "https://www.youtube.com/watch?v=VmB1G1K7v94"),
                Exercise(name: "Remada curvada", muscleGroup: .back, setsCount: 3, repsOrDuration: "12", videoURL: "https://www.youtube.com/watch?v=vT2GjY_Umpw"),
                Exercise(name: "Desenvolvimento de ombro", muscleGroup: .shoulders, setsCount: 3, repsOrDuration: "12", videoURL: "https://www.youtube.com/watch?v=qEwKCR5JCog"),
                Exercise(name: "Abdominal na polia ou solo", muscleGroup: .abs, setsCount: 3, repsOrDuration: "20", videoURL: "https://www.youtube.com/watch?v=1we3bh9uhqY")
            ],
            cardio: "20 min esteira (vel. 5, incl. 5%)",
            estimatedMinutes: 60
        )
    }

    private func makeTerca() -> DayWorkout {
        DayWorkout(
            day: "Terça-feira",
            muscleGroups: [.cardio, .abs],
            exercises: [
                Exercise(name: "Prancha isométrica", muscleGroup: .abs, setsCount: 3, repsOrDuration: "40s", videoURL: "https://www.youtube.com/watch?v=pSHjTRCQxIw"),
                Exercise(name: "Elevação de pernas na barra", muscleGroup: .abs, setsCount: 3, repsOrDuration: "15", videoURL: "https://www.youtube.com/watch?v=JB2oyawG9KI"),
                Exercise(name: "Bicicleta abdominal", muscleGroup: .abs, setsCount: 3, repsOrDuration: "20", videoURL: "https://www.youtube.com/watch?v=9FGilxCbdz8"),
                Exercise(name: "Abdominal infra com elevação", muscleGroup: .abs, setsCount: 3, repsOrDuration: "15", videoURL: "https://www.youtube.com/watch?v=JB2oyawG9KI")
            ],
            cardio: "30 min esteira (vel. 5, incl. 5%)",
            estimatedMinutes: 50
        )
    }

    private func makeQuarta() -> DayWorkout {
        DayWorkout(
            day: "Quarta-feira",
            muscleGroups: [.back, .biceps],
            exercises: [
                Exercise(name: "Puxada frente", muscleGroup: .back, setsCount: 4, repsOrDuration: "10", videoURL: "https://www.youtube.com/watch?v=CAwf7n6Luuc"),
                Exercise(name: "Remada unilateral", muscleGroup: .back, setsCount: 3, repsOrDuration: "12", videoURL: "https://www.youtube.com/watch?v=pYcpY20QaE8"),
                Exercise(name: "Pulldown no cross", muscleGroup: .back, setsCount: 3, repsOrDuration: "12", videoURL: "https://www.youtube.com/watch?v=AjCCGN2tU3Q"),
                Exercise(name: "Rosca direta", muscleGroup: .biceps, setsCount: 3, repsOrDuration: "12", videoURL: "https://www.youtube.com/watch?v=kwG2ipFRgfo"),
                Exercise(name: "Prancha com toque de ombro", muscleGroup: .abs, setsCount: 3, repsOrDuration: "30s", videoURL: "https://www.youtube.com/watch?v=ynUw0YsrmSg")
            ],
            cardio: "20 min escada ou esteira inclinada",
            estimatedMinutes: 55
        )
    }

    private func makeQuinta() -> DayWorkout {
        DayWorkout(
            day: "Quinta-feira",
            muscleGroups: [.legs, .glutes],
            exercises: [
                Exercise(name: "Leg press", muscleGroup: .legs, setsCount: 4, repsOrDuration: "12", videoURL: "https://www.youtube.com/watch?v=IZxyjW7MPJQ"),
                Exercise(name: "Afundo com halteres", muscleGroup: .legs, setsCount: 3, repsOrDuration: "10", videoURL: "https://www.youtube.com/watch?v=D7KaRcUTQeE"),
                Exercise(name: "Stiff com halteres", muscleGroup: .glutes, setsCount: 3, repsOrDuration: "12", videoURL: "https://www.youtube.com/watch?v=ytGaGIn3SjE"),
                Exercise(name: "Glute bridge", muscleGroup: .glutes, setsCount: 3, repsOrDuration: "15", videoURL: "https://www.youtube.com/watch?v=9qo48CYN06w"),
                Exercise(name: "Abdominal infra estendido", muscleGroup: .abs, setsCount: 3, repsOrDuration: "20", videoURL: "https://www.youtube.com/watch?v=JB2oyawG9KI")
            ],
            cardio: "15 min escada ou bike leve",
            estimatedMinutes: 55
        )
    }

    private func makeSexta() -> DayWorkout {
        DayWorkout(
            day: "Sexta-feira",
            muscleGroups: [.chest, .shoulders, .triceps],
            exercises: [
                Exercise(name: "Supino inclinado", muscleGroup: .chest, setsCount: 4, repsOrDuration: "10", videoURL: "https://www.youtube.com/watch?v=8iPEnn-ltC8"),
                Exercise(name: "Crossover ou peck deck", muscleGroup: .chest, setsCount: 3, repsOrDuration: "12", videoURL: "https://www.youtube.com/watch?v=taI4XduLpTk"),
                Exercise(name: "Elevação lateral", muscleGroup: .shoulders, setsCount: 3, repsOrDuration: "12", videoURL: "https://www.youtube.com/watch?v=kDqklk1ZESo"),
                Exercise(name: "Tríceps testa", muscleGroup: .triceps, setsCount: 3, repsOrDuration: "12", videoURL: "https://www.youtube.com/watch?v=d_KZxkY_0cM"),
                Exercise(name: "Prancha lateral", muscleGroup: .abs, setsCount: 3, repsOrDuration: "30s/lado", videoURL: "https://www.youtube.com/watch?v=K2VljzCC16g")
            ],
            cardio: "20–30 min esteira (zona 2)",
            estimatedMinutes: 60
        )
    }
}
