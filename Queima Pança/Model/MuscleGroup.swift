import Foundation

enum MuscleGroup: String, CaseIterable, Identifiable {
    case chest = "Peito"
    case back = "Costas"
    case shoulders = "Ombros"
    case biceps = "Bíceps"
    case triceps = "Tríceps"
    case legs = "Pernas"
    case glutes = "Glúteos"
    case abs = "Abdômen"
    case fullBody = "Full Body"
    case cardio = "Cardio"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .chest: return "figure.strengthtraining.traditional"
        case .back: return "figure.rowing"
        case .shoulders: return "figure.arms.open"
        case .biceps: return "figure.strengthtraining.functional"
        case .triceps: return "figure.strengthtraining.functional"
        case .legs: return "figure.walk"
        case .glutes: return "figure.cooldown"
        case .abs: return "figure.core.training"
        case .fullBody: return "figure.mixed.cardio"
        case .cardio: return "figure.run"
        }
    }
}
