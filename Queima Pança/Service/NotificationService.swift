import Foundation
import UserNotifications

// MARK: - Notification Service

final class NotificationService {

    static let shared = NotificationService()
    private init() {}

    // MARK: - Permission

    func requestPermission(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            DispatchQueue.main.async {
                completion(granted)
            }
        }
    }

    // MARK: - Schedule Workout Reminders

    /// Schedule daily workout reminders for each training day
    func scheduleWorkoutReminders(at hour: Int = 7, minute: Int = 0) {
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()

        let workoutDays: [(weekday: Int, title: String)] = [
            (2, "Segunda-feira — Full Body 💪"),
            (3, "Terça-feira — Cardio + Abdômen 🏃"),
            (4, "Quarta-feira — Costas + Bíceps 🔥"),
            (5, "Quinta-feira — Pernas + Glúteos 🦵"),
            (6, "Sexta-feira — Peito + Ombro + Tríceps 💥")
        ]

        for day in workoutDays {
            let content = UNMutableNotificationContent()
            content.title = "🔥 Queima Pança"
            content.body = "Hoje é dia de treino: \(day.title)"
            content.sound = .default

            var dateComponents = DateComponents()
            dateComponents.weekday = day.weekday
            dateComponents.hour = hour
            dateComponents.minute = minute

            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
            let request = UNNotificationRequest(
                identifier: "workout-day-\(day.weekday)",
                content: content,
                trigger: trigger
            )

            center.add(request)
        }
    }

    /// Schedule a single reminder for rest day (Saturday/Sunday)
    func scheduleRestDayMessage(at hour: Int = 9, minute: Int = 0) {
        let center = UNUserNotificationCenter.current()

        let content = UNMutableNotificationContent()
        content.title = "🔥 Queima Pança"
        content.body = "Hoje é dia de descanso! Recupere-se para a próxima semana 😴"
        content.sound = .default

        for weekday in [1, 7] { // Sunday = 1, Saturday = 7
            var dateComponents = DateComponents()
            dateComponents.weekday = weekday
            dateComponents.hour = hour
            dateComponents.minute = minute

            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
            let request = UNNotificationRequest(
                identifier: "rest-day-\(weekday)",
                content: content,
                trigger: trigger
            )

            center.add(request)
        }
    }

    // MARK: - Cancel

    func cancelAllReminders() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }

    // MARK: - Check Status

    func checkPermissionStatus(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                completion(settings.authorizationStatus == .authorized)
            }
        }
    }
}
