import SwiftUI

// MARK: - Confetti View

struct ConfettiView: View {
    @State private var particles: [ConfettiParticle] = []
    @State private var isAnimating = false

    private let colors: [Color] = [.orange, .red, .yellow, .green, .blue, .purple, .pink]
    private let emojis = ["🔥", "💪", "⭐", "🏆", "✨", "🎯", "💥"]
    private let particleCount = 50

    var body: some View {
        ZStack {
            ForEach(particles) { particle in
                Text(particle.emoji)
                    .font(.system(size: particle.size))
                    .position(particle.position)
                    .opacity(particle.opacity)
                    .rotationEffect(.degrees(particle.rotation))
            }
        }
        .allowsHitTesting(false)
        .onAppear {
            createParticles()
            startAnimation()
        }
    }

    private func createParticles() {
        let screenWidth = UIScreen.main.bounds.width
        particles = (0..<particleCount).map { _ in
            ConfettiParticle(
                emoji: emojis.randomElement()!,
                position: CGPoint(
                    x: CGFloat.random(in: 0...screenWidth),
                    y: -20
                ),
                size: CGFloat.random(in: 14...28),
                opacity: 1.0,
                rotation: 0,
                targetX: CGFloat.random(in: -40...40),
                speed: Double.random(in: 1.5...3.0)
            )
        }
    }

    private func startAnimation() {
        let screenHeight = UIScreen.main.bounds.height

        for i in particles.indices {
            let delay = Double.random(in: 0...0.8)

            withAnimation(
                .easeOut(duration: particles[i].speed)
                .delay(delay)
            ) {
                particles[i].position = CGPoint(
                    x: particles[i].position.x + particles[i].targetX,
                    y: screenHeight + 50
                )
                particles[i].rotation = Double.random(in: -360...360)
            }

            withAnimation(
                .easeIn(duration: 0.5)
                .delay(delay + particles[i].speed - 0.5)
            ) {
                particles[i].opacity = 0
            }
        }
    }
}

// MARK: - Confetti Particle

struct ConfettiParticle: Identifiable {
    let id = UUID()
    let emoji: String
    var position: CGPoint
    let size: CGFloat
    var opacity: Double
    var rotation: Double
    let targetX: CGFloat
    let speed: Double
}

// MARK: - Confetti Overlay Modifier

struct ConfettiOverlay: ViewModifier {
    @Binding var isActive: Bool

    func body(content: Content) -> some View {
        content
            .overlay {
                if isActive {
                    ConfettiView()
                        .ignoresSafeArea()
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                isActive = false
                            }
                        }
                }
            }
    }
}

extension View {
    func confettiOverlay(isActive: Binding<Bool>) -> some View {
        modifier(ConfettiOverlay(isActive: isActive))
    }
}
