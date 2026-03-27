import Foundation

// MARK: - Exercise Catalog

/// A catalog entry for picking exercises when building custom workouts
struct CatalogExercise: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let muscleGroup: MuscleGroup
    let defaultSets: Int
    let defaultReps: String
    let videoURL: String

    func hash(into hasher: inout Hasher) { hasher.combine(name) }
    static func == (lhs: CatalogExercise, rhs: CatalogExercise) -> Bool { lhs.name == rhs.name }
}

enum ExerciseCatalog {

    static let all: [CatalogExercise] = chest + back + shoulders + biceps + triceps + legs + glutes + abs + cardio

    // MARK: - By Group

    static func exercises(for group: MuscleGroup) -> [CatalogExercise] {
        all.filter { $0.muscleGroup == group }
    }

    // MARK: - Peito

    static let chest: [CatalogExercise] = [
        .init(name: "Supino reto com barra", muscleGroup: .chest, defaultSets: 4, defaultReps: "10", videoURL: "https://www.youtube.com/watch?v=rT7DgCr-3pg"),
        .init(name: "Supino reto com halteres", muscleGroup: .chest, defaultSets: 4, defaultReps: "10", videoURL: "https://www.youtube.com/watch?v=VmB1G1K7v94"),
        .init(name: "Supino inclinado", muscleGroup: .chest, defaultSets: 4, defaultReps: "10", videoURL: "https://www.youtube.com/watch?v=8iPEnn-ltC8"),
        .init(name: "Supino declinado", muscleGroup: .chest, defaultSets: 3, defaultReps: "12", videoURL: "https://www.youtube.com/watch?v=LfyQBUKR8SE"),
        .init(name: "Crossover", muscleGroup: .chest, defaultSets: 3, defaultReps: "12", videoURL: "https://www.youtube.com/watch?v=taI4XduLpTk"),
        .init(name: "Peck Deck (voador)", muscleGroup: .chest, defaultSets: 3, defaultReps: "12", videoURL: "https://www.youtube.com/watch?v=Z57CtFmRMxA"),
        .init(name: "Flexão de braço", muscleGroup: .chest, defaultSets: 3, defaultReps: "15", videoURL: "https://www.youtube.com/watch?v=IODxDxX7oi4"),
        .init(name: "Crucifixo com halteres", muscleGroup: .chest, defaultSets: 3, defaultReps: "12", videoURL: "https://www.youtube.com/watch?v=eozdVDA78K0"),
    ]

    // MARK: - Costas

    static let back: [CatalogExercise] = [
        .init(name: "Puxada frente", muscleGroup: .back, defaultSets: 4, defaultReps: "10", videoURL: "https://www.youtube.com/watch?v=CAwf7n6Luuc"),
        .init(name: "Remada curvada", muscleGroup: .back, defaultSets: 3, defaultReps: "12", videoURL: "https://www.youtube.com/watch?v=vT2GjY_Umpw"),
        .init(name: "Remada unilateral", muscleGroup: .back, defaultSets: 3, defaultReps: "12", videoURL: "https://www.youtube.com/watch?v=pYcpY20QaE8"),
        .init(name: "Pulldown no cross", muscleGroup: .back, defaultSets: 3, defaultReps: "12", videoURL: "https://www.youtube.com/watch?v=AjCCGN2tU3Q"),
        .init(name: "Remada cavaleiro", muscleGroup: .back, defaultSets: 3, defaultReps: "12", videoURL: "https://www.youtube.com/watch?v=roCP6wCXPqo"),
        .init(name: "Barra fixa", muscleGroup: .back, defaultSets: 3, defaultReps: "8", videoURL: "https://www.youtube.com/watch?v=eGo4IYlbE5g"),
        .init(name: "Serrote", muscleGroup: .back, defaultSets: 3, defaultReps: "12", videoURL: "https://www.youtube.com/watch?v=pYcpY20QaE8"),
    ]

    // MARK: - Ombros

    static let shoulders: [CatalogExercise] = [
        .init(name: "Desenvolvimento com halteres", muscleGroup: .shoulders, defaultSets: 3, defaultReps: "12", videoURL: "https://www.youtube.com/watch?v=qEwKCR5JCog"),
        .init(name: "Desenvolvimento máquina", muscleGroup: .shoulders, defaultSets: 3, defaultReps: "12", videoURL: "https://www.youtube.com/watch?v=qEwKCR5JCog"),
        .init(name: "Elevação lateral", muscleGroup: .shoulders, defaultSets: 3, defaultReps: "12", videoURL: "https://www.youtube.com/watch?v=kDqklk1ZESo"),
        .init(name: "Elevação frontal", muscleGroup: .shoulders, defaultSets: 3, defaultReps: "12", videoURL: "https://www.youtube.com/watch?v=gzDe2JMDjVc"),
        .init(name: "Face pull", muscleGroup: .shoulders, defaultSets: 3, defaultReps: "15", videoURL: "https://www.youtube.com/watch?v=rep-qVOkqgk"),
        .init(name: "Encolhimento com halteres", muscleGroup: .shoulders, defaultSets: 3, defaultReps: "15", videoURL: "https://www.youtube.com/watch?v=g6qbq4Lf1FI"),
    ]

    // MARK: - Bíceps

    static let biceps: [CatalogExercise] = [
        .init(name: "Rosca direta", muscleGroup: .biceps, defaultSets: 3, defaultReps: "12", videoURL: "https://www.youtube.com/watch?v=kwG2ipFRgfo"),
        .init(name: "Rosca alternada", muscleGroup: .biceps, defaultSets: 3, defaultReps: "10", videoURL: "https://www.youtube.com/watch?v=sAq_ocpRh_I"),
        .init(name: "Rosca martelo", muscleGroup: .biceps, defaultSets: 3, defaultReps: "12", videoURL: "https://www.youtube.com/watch?v=zC3nLlEvin4"),
        .init(name: "Rosca concentrada", muscleGroup: .biceps, defaultSets: 3, defaultReps: "12", videoURL: "https://www.youtube.com/watch?v=VMbax-IKLHI"),
        .init(name: "Rosca Scott", muscleGroup: .biceps, defaultSets: 3, defaultReps: "12", videoURL: "https://www.youtube.com/watch?v=soxrZlIl35U"),
    ]

    // MARK: - Tríceps

    static let triceps: [CatalogExercise] = [
        .init(name: "Tríceps testa", muscleGroup: .triceps, defaultSets: 3, defaultReps: "12", videoURL: "https://www.youtube.com/watch?v=d_KZxkY_0cM"),
        .init(name: "Tríceps pulley", muscleGroup: .triceps, defaultSets: 3, defaultReps: "12", videoURL: "https://www.youtube.com/watch?v=2-LAMcpzODU"),
        .init(name: "Tríceps corda", muscleGroup: .triceps, defaultSets: 3, defaultReps: "12", videoURL: "https://www.youtube.com/watch?v=kiuVA0gs3EI"),
        .init(name: "Tríceps francês", muscleGroup: .triceps, defaultSets: 3, defaultReps: "10", videoURL: "https://www.youtube.com/watch?v=_gsUck-7M74"),
        .init(name: "Mergulho no banco", muscleGroup: .triceps, defaultSets: 3, defaultReps: "12", videoURL: "https://www.youtube.com/watch?v=6kALZikXxLc"),
    ]

    // MARK: - Pernas

    static let legs: [CatalogExercise] = [
        .init(name: "Agachamento livre", muscleGroup: .legs, defaultSets: 4, defaultReps: "10", videoURL: "https://www.youtube.com/watch?v=aclHkVaku9U"),
        .init(name: "Agachamento Smith", muscleGroup: .legs, defaultSets: 4, defaultReps: "10", videoURL: "https://www.youtube.com/watch?v=aclHkVaku9U"),
        .init(name: "Leg press", muscleGroup: .legs, defaultSets: 4, defaultReps: "12", videoURL: "https://www.youtube.com/watch?v=IZxyjW7MPJQ"),
        .init(name: "Cadeira extensora", muscleGroup: .legs, defaultSets: 3, defaultReps: "12", videoURL: "https://www.youtube.com/watch?v=YyvSfVjQeL0"),
        .init(name: "Mesa flexora", muscleGroup: .legs, defaultSets: 3, defaultReps: "12", videoURL: "https://www.youtube.com/watch?v=1Tq3QdYUuHs"),
        .init(name: "Afundo com halteres", muscleGroup: .legs, defaultSets: 3, defaultReps: "10", videoURL: "https://www.youtube.com/watch?v=D7KaRcUTQeE"),
        .init(name: "Panturrilha em pé", muscleGroup: .legs, defaultSets: 4, defaultReps: "15", videoURL: "https://www.youtube.com/watch?v=gwLzBJYoWlI"),
        .init(name: "Panturrilha sentado", muscleGroup: .legs, defaultSets: 4, defaultReps: "15", videoURL: "https://www.youtube.com/watch?v=JbyjNymZOt0"),
    ]

    // MARK: - Glúteos

    static let glutes: [CatalogExercise] = [
        .init(name: "Stiff com halteres", muscleGroup: .glutes, defaultSets: 3, defaultReps: "12", videoURL: "https://www.youtube.com/watch?v=ytGaGIn3SjE"),
        .init(name: "Glute bridge", muscleGroup: .glutes, defaultSets: 3, defaultReps: "15", videoURL: "https://www.youtube.com/watch?v=9qo48CYN06w"),
        .init(name: "Hip thrust", muscleGroup: .glutes, defaultSets: 4, defaultReps: "12", videoURL: "https://www.youtube.com/watch?v=SEdqd1n0icg"),
        .init(name: "Abdução na máquina", muscleGroup: .glutes, defaultSets: 3, defaultReps: "15", videoURL: "https://www.youtube.com/watch?v=sJ5mA5MR-Io"),
        .init(name: "Passada búlgara", muscleGroup: .glutes, defaultSets: 3, defaultReps: "10", videoURL: "https://www.youtube.com/watch?v=2C-uNgKwPLE"),
    ]

    // MARK: - Abdômen

    static let abs: [CatalogExercise] = [
        .init(name: "Abdominal crunch", muscleGroup: .abs, defaultSets: 3, defaultReps: "20", videoURL: "https://www.youtube.com/watch?v=1we3bh9uhqY"),
        .init(name: "Prancha isométrica", muscleGroup: .abs, defaultSets: 3, defaultReps: "40s", videoURL: "https://www.youtube.com/watch?v=pSHjTRCQxIw"),
        .init(name: "Elevação de pernas", muscleGroup: .abs, defaultSets: 3, defaultReps: "15", videoURL: "https://www.youtube.com/watch?v=JB2oyawG9KI"),
        .init(name: "Bicicleta abdominal", muscleGroup: .abs, defaultSets: 3, defaultReps: "20", videoURL: "https://www.youtube.com/watch?v=9FGilxCbdz8"),
        .init(name: "Prancha lateral", muscleGroup: .abs, defaultSets: 3, defaultReps: "30s", videoURL: "https://www.youtube.com/watch?v=K2VljzCC16g"),
        .init(name: "Abdominal infra", muscleGroup: .abs, defaultSets: 3, defaultReps: "15", videoURL: "https://www.youtube.com/watch?v=JB2oyawG9KI"),
        .init(name: "Prancha com toque de ombro", muscleGroup: .abs, defaultSets: 3, defaultReps: "30s", videoURL: "https://www.youtube.com/watch?v=ynUw0YsrmSg"),
    ]

    // MARK: - Cardio

    static let cardio: [CatalogExercise] = [
        .init(name: "Corrida na esteira", muscleGroup: .cardio, defaultSets: 1, defaultReps: "20 min", videoURL: ""),
        .init(name: "Caminhada inclinada", muscleGroup: .cardio, defaultSets: 1, defaultReps: "30 min", videoURL: ""),
        .init(name: "Bicicleta ergométrica", muscleGroup: .cardio, defaultSets: 1, defaultReps: "20 min", videoURL: ""),
        .init(name: "Elíptico", muscleGroup: .cardio, defaultSets: 1, defaultReps: "20 min", videoURL: ""),
        .init(name: "Escada", muscleGroup: .cardio, defaultSets: 1, defaultReps: "15 min", videoURL: ""),
        .init(name: "Pular corda", muscleGroup: .cardio, defaultSets: 3, defaultReps: "3 min", videoURL: ""),
    ]
}
