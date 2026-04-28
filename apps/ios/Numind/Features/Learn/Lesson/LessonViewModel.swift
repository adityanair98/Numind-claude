import Foundation

struct LessonViewModel {
    let lesson: Lesson
    let moduleTitle: String
    let lessonIndex: Int    // 0-based position in module
    let totalLessons: Int

    var contextLabel: String { "\(moduleTitle) · Lesson \(lessonIndex + 1)" }
    var stepLabel: String    { "\(lessonIndex + 1) / \(totalLessons)" }
    var progress: Double     { Double(lessonIndex + 1) / Double(max(totalLessons, 1)) }
}
