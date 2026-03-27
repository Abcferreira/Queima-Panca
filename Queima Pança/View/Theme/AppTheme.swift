import SwiftUI

// MARK: - App Theme

enum AppTheme {

    // MARK: - Colors (adaptive light/dark)
    static let primary = Color.orange
    static let secondary = Color.orange.opacity(0.15)
    static let accent = Color.red

    /// Adaptive card background — light gray in light mode, darker in dark mode
    static var cardBackground: Color {
        Color(light: Color(.systemBackground), dark: Color(.secondarySystemBackground))
    }

    /// Adaptive main background
    static var background: Color {
        Color(light: Color(.systemGroupedBackground), dark: Color(.systemBackground))
    }

    // MARK: - Gradients
    static let primaryGradient = LinearGradient(
        colors: [.orange, .red],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    // MARK: - Corner Radius
    static let cornerRadius: CGFloat = 16
    static let smallCornerRadius: CGFloat = 10

    // MARK: - Shadows
    static let cardShadowRadius: CGFloat = 8

    static var cardShadow: Color {
        Color(light: Color.black.opacity(0.08), dark: Color.black.opacity(0.3))
    }
}

// MARK: - Adaptive Color Helper

extension Color {
    init(light: Color, dark: Color) {
        self.init(uiColor: UIColor { traits in
            traits.userInterfaceStyle == .dark
                ? UIColor(dark)
                : UIColor(light)
        })
    }
}

// MARK: - View Modifiers

struct FitnessCardModifier: ViewModifier {
    @Environment(\.colorScheme) var colorScheme

    func body(content: Content) -> some View {
        content
            .padding(16)
            .background(AppTheme.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadius))
            .shadow(
                color: colorScheme == .dark ? .clear : AppTheme.cardShadow,
                radius: AppTheme.cardShadowRadius,
                y: 4
            )
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                    .stroke(colorScheme == .dark ? Color.white.opacity(0.08) : .clear, lineWidth: 1)
            )
    }
}

struct PrimaryButtonModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.headline)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(AppTheme.primaryGradient)
            .foregroundColor(.white)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.smallCornerRadius))
    }
}

extension View {
    func fitnessCard() -> some View {
        modifier(FitnessCardModifier())
    }

    func primaryButton() -> some View {
        modifier(PrimaryButtonModifier())
    }
}
