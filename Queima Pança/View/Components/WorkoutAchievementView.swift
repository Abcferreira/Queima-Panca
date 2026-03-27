import SwiftUI

// MARK: - Workout Achievement View

struct WorkoutAchievementView: View {
    let workout: DayWorkout
    let totalWeight: Double
    let completedSets: Int
    let totalSets: Int
    @Environment(\.dismiss) private var dismiss
    @State private var showConfetti = true
    @State private var appearAnimation = false

    var body: some View {
        ZStack {
            // Background
            AppTheme.background.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {

                    // MARK: - Trophy
                    trophySection

                    // MARK: - Stats
                    statsSection

                    // MARK: - Weight Equivalent
                    weightEquivalentSection

                    // MARK: - Share Button
                    shareButton

                    // MARK: - Close
                    Button {
                        dismiss()
                    } label: {
                        Text("Continuar 💪")
                            .primaryButton()
                    }
                }
                .padding(.horizontal)
                .padding(.top, 24)
                .padding(.bottom, 40)
            }

            // Confetti overlay
            if showConfetti {
                ConfettiView()
                    .ignoresSafeArea()
                    .allowsHitTesting(false)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                appearAnimation = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                showConfetti = false
            }
        }
    }

    // MARK: - Trophy Section

    private var trophySection: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [.yellow.opacity(0.3), .orange.opacity(0.1), .clear],
                            center: .center,
                            startRadius: 20,
                            endRadius: 80
                        )
                    )
                    .frame(width: 160, height: 160)

                Image(systemName: "trophy.fill")
                    .font(.system(size: 70))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.yellow, .orange],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .scaleEffect(appearAnimation ? 1.0 : 0.3)
            }

            Text("Treino Concluído!")
                .font(.title.bold())
                .opacity(appearAnimation ? 1 : 0)
                .offset(y: appearAnimation ? 0 : 20)

            Text(workout.day)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .opacity(appearAnimation ? 1 : 0)
        }
    }

    // MARK: - Stats Section

    private var statsSection: some View {
        HStack(spacing: 0) {
            statItem(
                icon: "checkmark.circle.fill",
                color: .green,
                value: "\(completedSets)/\(totalSets)",
                label: "Séries"
            )

            Divider().frame(height: 40)

            statItem(
                icon: "scalemass.fill",
                color: .orange,
                value: weightFormatted,
                label: "Peso total"
            )

            Divider().frame(height: 40)

            statItem(
                icon: "clock.fill",
                color: .blue,
                value: "~\(workout.estimatedMinutes)min",
                label: "Duração"
            )
        }
        .fitnessCard()
        .scaleEffect(appearAnimation ? 1.0 : 0.8)
        .opacity(appearAnimation ? 1 : 0)
    }

    private func statItem(icon: String, color: Color, value: String, label: String) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)

            Text(value)
                .font(.subheadline.bold())

            Text(label)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Weight Equivalent Section

    private var weightEquivalentSection: some View {
        VStack(spacing: 16) {
            Text("Você levantou o equivalente a...")
                .font(.headline)

            let equivalent = weightEquivalent

            VStack(spacing: 12) {
                Image(systemName: equivalent.icon)
                    .font(.system(size: 50))
                    .foregroundStyle(AppTheme.primaryGradient)

                Text(equivalent.description)
                    .font(.title3.bold())
                    .multilineTextAlignment(.center)

                Text(equivalent.funFact)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            .padding(.vertical, 8)
        }
        .fitnessCard()
        .scaleEffect(appearAnimation ? 1.0 : 0.8)
        .opacity(appearAnimation ? 1 : 0)
    }

    // MARK: - Share Button

    private var shareButton: some View {
        ShareLink(
            item: shareText,
            subject: Text("Treino Concluído! 🔥"),
            message: Text(shareText)
        ) {
            HStack {
                Image(systemName: "square.and.arrow.up")
                Text("Compartilhar nas Redes")
            }
            .font(.headline)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(Color.blue)
            .foregroundColor(.white)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.smallCornerRadius))
        }
        .opacity(appearAnimation ? 1 : 0)
    }

    // MARK: - Helpers

    private var weightFormatted: String {
        if totalWeight >= 1000 {
            return String(format: "%.1ft", totalWeight / 1000)
        }
        return String(format: "%.0fkg", totalWeight)
    }

    private var shareText: String {
        """
        🔥 Treino concluído no Queima Pança!

        📋 \(workout.day) — \(workout.subtitle)
        ✅ \(completedSets)/\(totalSets) séries feitas
        🏋️ \(weightFormatted) levantados
        💪 Equivalente a \(weightEquivalent.shortDesc)

        #QueimaPança #Fitness #Treino
        """
    }

    // MARK: - Weight Equivalents

    private var weightEquivalent: WeightEquivalent {
        let kg = totalWeight

        if kg >= 10000 {
            let count = kg / 1500
            return WeightEquivalent(
                icon: "car.fill",
                description: String(format: "%.1f carros populares! 🚗", count),
                shortDesc: String(format: "%.1f carros", count),
                funFact: "Um carro popular pesa cerca de 1.500kg. Você é uma máquina!"
            )
        } else if kg >= 5000 {
            let count = kg / 800
            return WeightEquivalent(
                icon: "bicycle",
                description: String(format: "%.0f motos! 🏍️", count),
                shortDesc: String(format: "%.0f motos", count),
                funFact: "Uma moto esportiva pesa em média 800kg com o piloto."
            )
        } else if kg >= 2000 {
            let count = kg / 500
            return WeightEquivalent(
                icon: "pianokeys",
                description: String(format: "%.0f pianos de cauda! 🎹", count),
                shortDesc: String(format: "%.0f pianos", count),
                funFact: "Um piano de cauda pesa cerca de 500kg. Nada mal!"
            )
        } else if kg >= 1000 {
            let count = kg / 250
            return WeightEquivalent(
                icon: "figure.strengthtraining.traditional",
                description: String(format: "%.0f geladeiras! 🧊", count),
                shortDesc: String(format: "%.0f geladeiras", count),
                funFact: "Uma geladeira duplex pesa cerca de 250kg. Forte demais!"
            )
        } else if kg >= 500 {
            let count = kg / 113
            return WeightEquivalent(
                icon: "figure.wrestling",
                description: String(format: "%.0f lutadores de sumô! 🤼", count),
                shortDesc: String(format: "%.0f lutadores de sumô", count),
                funFact: "Um lutador de sumô profissional pesa em média 113kg."
            )
        } else if kg >= 200 {
            let count = kg / 70
            return WeightEquivalent(
                icon: "figure.run",
                description: String(format: "%.0f pessoas adultas! 🧑‍🤝‍🧑", count),
                shortDesc: String(format: "%.0f pessoas", count),
                funFact: "Uma pessoa adulta pesa em média 70kg."
            )
        } else if kg >= 50 {
            let count = kg / 7
            return WeightEquivalent(
                icon: "dog.fill",
                description: String(format: "%.0f cachorros labradores! 🐕", count),
                shortDesc: String(format: "%.0f labradores", count),
                funFact: "Um labrador adulto pesa em média 7kg... quer dizer, 30kg 😄"
            )
        } else if kg > 0 {
            let count = kg / 4.5
            return WeightEquivalent(
                icon: "cat.fill",
                description: String(format: "%.0f gatos gordos! 🐱", count),
                shortDesc: String(format: "%.0f gatos", count),
                funFact: "Um gato 'fofo' pesa cerca de 4.5kg. Bom começo!"
            )
        } else {
            return WeightEquivalent(
                icon: "flame.fill",
                description: "O treino foi mais cardio! 🔥",
                shortDesc: "treino cardio",
                funFact: "Nem todo treino é sobre peso. Você queimou muitas calorias!"
            )
        }
    }
}

// MARK: - Weight Equivalent Model

struct WeightEquivalent {
    let icon: String
    let description: String
    let shortDesc: String
    let funFact: String
}
