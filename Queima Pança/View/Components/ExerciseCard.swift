import SwiftUI

// MARK: - Exercise Card Component

struct ExerciseCard: View {
    let exercise: Exercise
    let completedSetsCount: Int
    let onToggleSet: (Int) -> Void
    let onVideoTap: () -> Void

    private var isCompleted: Bool {
        completedSetsCount >= exercise.setsCount
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if isCompleted {
                completedView
            } else {
                expandedView
            }
        }
        .fitnessCard()
        .animation(.easeInOut(duration: 0.35), value: isCompleted)
    }

    // MARK: - Completed (collapsed)

    private var completedView: some View {
        HStack(spacing: 12) {
            Image(systemName: "checkmark.circle.fill")
                .font(.title2)
                .foregroundColor(.green)

            VStack(alignment: .leading, spacing: 2) {
                Text(exercise.name)
                    .font(.subheadline.bold())
                    .strikethrough(true, color: .secondary.opacity(0.5))
                    .foregroundColor(.secondary)

                HStack(spacing: 6) {
                    Text(exercise.setsDisplay)
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Text("·")
                        .foregroundColor(.secondary)

                    Text(exercise.muscleGroup.rawValue)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            Spacer()

            Text("Concluído")
                .font(.caption2.bold())
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.green.opacity(0.15))
                .foregroundColor(.green)
                .clipShape(Capsule())
        }
    }

    // MARK: - Expanded (in progress)

    private var expandedView: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Video Thumbnail
            if let url = exercise.thumbnailURL {
                Button(action: onVideoTap) {
                    ZStack(alignment: .bottomLeading) {
                        AsyncImage(url: url) { phase in
                            switch phase {
                            case .empty:
                                RoundedRectangle(cornerRadius: AppTheme.smallCornerRadius)
                                    .fill(Color.gray.opacity(0.15))
                                    .frame(height: 180)
                                    .overlay(ProgressView())
                            case .success(let image):
                                image
                                    .resizable()
                                    .aspectRatio(16/9, contentMode: .fit)
                                    .clipShape(RoundedRectangle(cornerRadius: AppTheme.smallCornerRadius))
                            case .failure:
                                RoundedRectangle(cornerRadius: AppTheme.smallCornerRadius)
                                    .fill(Color.gray.opacity(0.15))
                                    .frame(height: 180)
                                    .overlay(
                                        Image(systemName: "play.slash")
                                            .foregroundColor(.secondary)
                                    )
                            @unknown default:
                                EmptyView()
                            }
                        }

                        // Play badge
                        HStack(spacing: 4) {
                            Image(systemName: "play.fill")
                                .font(.caption2)
                            Text("Ver vídeo")
                                .font(.caption2.bold())
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(.ultraThinMaterial)
                        .clipShape(Capsule())
                        .padding(8)
                    }
                }
                .buttonStyle(.plain)
            }

            // Exercise Info
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(exercise.name)
                        .font(.headline)

                    HStack(spacing: 8) {
                        Label(exercise.setsDisplay, systemImage: "repeat")
                            .font(.subheadline)
                            .foregroundColor(.secondary)

                        Text("•")
                            .foregroundColor(.secondary)

                        Label(exercise.muscleGroup.rawValue, systemImage: exercise.muscleGroup.icon)
                            .font(.caption)
                            .foregroundColor(AppTheme.primary)
                    }
                }

                Spacer()

                // Mini progress
                Text("\(completedSetsCount)/\(exercise.setsCount)")
                    .font(.caption.bold())
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(AppTheme.secondary)
                    .foregroundColor(AppTheme.primary)
                    .clipShape(Capsule())
            }

            // Notes
            if !exercise.notes.isEmpty {
                Text(exercise.notes)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 4)
            }

            // Set Tracker
            HStack(spacing: 8) {
                ForEach(0..<exercise.setsCount, id: \.self) { index in
                    Button(action: { onToggleSet(index) }) {
                        VStack(spacing: 2) {
                            Image(systemName: index < completedSetsCount
                                  ? "checkmark.circle.fill"
                                  : "circle")
                                .font(.title3)
                                .foregroundColor(index < completedSetsCount ? .green : .gray.opacity(0.4))

                            Text("S\(index + 1)")
                                .font(.system(size: 9, weight: .medium))
                                .foregroundColor(.secondary)
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.top, 4)
        }
    }
}
