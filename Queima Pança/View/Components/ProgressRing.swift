import SwiftUI

// MARK: - Progress Ring Component

struct ProgressRing: View {
    let progress: Double
    let lineWidth: CGFloat
    let size: CGFloat

    init(progress: Double, size: CGFloat = 50, lineWidth: CGFloat = 5) {
        self.progress = progress
        self.size = size
        self.lineWidth = lineWidth
    }

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.gray.opacity(0.2), lineWidth: lineWidth)

            Circle()
                .trim(from: 0, to: min(progress, 1.0))
                .stroke(
                    AppTheme.primaryGradient,
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 0.3), value: progress)

            Text("\(Int(progress * 100))%")
                .font(.system(size: size * 0.22, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
        }
        .frame(width: size, height: size)
    }
}
