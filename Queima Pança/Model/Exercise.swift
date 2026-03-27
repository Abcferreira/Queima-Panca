//
//  Exercise.swift
//  Queima Pança
//
//  Created by Anderson Borges Costa Ferreira on 18/07/25.
//
import Foundation

// MARK: - Exercise Model

struct Exercise: Identifiable, Hashable {
    let id: UUID
    let name: String
    let muscleGroup: MuscleGroup
    let setsCount: Int
    let repsOrDuration: String
    let notes: String
    let videoURL: String

    /// Formatted sets string, e.g. "4x10" or "3x30s"
    var setsDisplay: String {
        "\(setsCount)x\(repsOrDuration)"
    }

    /// YouTube thumbnail extracted from video URL
    var thumbnailURL: URL? {
        guard let videoID = videoURL.components(separatedBy: "v=").last else {
            return nil
        }
        return URL(string: "https://img.youtube.com/vi/\(videoID)/hqdefault.jpg")
    }

    /// Convenience initializer with auto-generated UUID
    init(
        id: UUID = UUID(),
        name: String,
        muscleGroup: MuscleGroup,
        setsCount: Int,
        repsOrDuration: String,
        notes: String = "",
        videoURL: String
    ) {
        self.id = id
        self.name = name
        self.muscleGroup = muscleGroup
        self.setsCount = setsCount
        self.repsOrDuration = repsOrDuration
        self.notes = notes
        self.videoURL = videoURL
    }

    // MARK: - Hashable
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: Exercise, rhs: Exercise) -> Bool {
        lhs.id == rhs.id
    }
}
