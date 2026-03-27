import SwiftUI

// MARK: - Rest Timer View

struct RestTimerView: View {
    @ObservedObject var timerVM: RestTimerViewModel

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            // Title
            HStack(spacing: 8) {
                Image(systemName: "timer")
                    .font(.title2)
                    .foregroundColor(.orange)
                Text("Tempo de Descanso")
                    .font(.title2.bold())
            }

            // Circular Timer
            ZStack {
                // Background circle
                Circle()
                    .stroke(Color.gray.opacity(0.2), lineWidth: 12)
                    .frame(width: 200, height: 200)

                // Progress circle
                Circle()
                    .trim(from: 0, to: 1 - timerVM.progress)
                    .stroke(
                        timerGradient,
                        style: StrokeStyle(lineWidth: 12, lineCap: .round)
                    )
                    .frame(width: 200, height: 200)
                    .rotationEffect(.degrees(-90))
                    .animation(.linear(duration: 1), value: timerVM.progress)

                // Time text
                VStack(spacing: 4) {
                    Text(timerVM.timeFormatted)
                        .font(.system(size: 48, weight: .bold, design: .monospaced))
                        .foregroundColor(.primary)

                    Text(timerVM.isRunning ? "descansando..." : "finalizado!")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.vertical, 16)

            // Quick-add buttons
            HStack(spacing: 16) {
                quickAddButton(seconds: 15)
                quickAddButton(seconds: 30)
                quickAddButton(seconds: 60)
            }

            Spacer()

            // Dismiss button
            Button(action: { timerVM.dismiss() }) {
                Label("Fechar", systemImage: "xmark.circle.fill")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color.orange.gradient)
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 24)
        }
        .background(Color(.systemBackground))
    }

    // MARK: - Subviews

    private func quickAddButton(seconds: Int) -> some View {
        Button(action: { timerVM.addTime(seconds) }) {
            Text("+\(seconds)s")
                .font(.subheadline.bold())
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color.orange.opacity(0.15))
                .foregroundColor(.orange)
                .clipShape(Capsule())
        }
    }

    private var timerGradient: AngularGradient {
        AngularGradient(
            gradient: Gradient(colors: [.orange, .red, .orange]),
            center: .center
        )
    }
}
