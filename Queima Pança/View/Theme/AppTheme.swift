import SwiftUI

// MARK: - App Theme

enum AppTheme {

    // MARK: - Colors
    static let primary = Color.orange
    static let secondary = Color.orange.opacity(0.15)
    static let accent = Color.red
    static let cardBackground = Color.gray.opacity(0.1)
    static let background = Color.white

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
    static let cardShadow: Color = Color.black.opacity(0.08)
    static let cardShadowRadius: CGFloat = 8
}

// MARK: - View Modifiers

struct FitnessCardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(16)
            .background(AppTheme.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadius))
            .shadow(color: AppTheme.cardShadow, radius: AppTheme.cardShadowRadius, y: 4)
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
