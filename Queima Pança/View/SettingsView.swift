import SwiftUI

// MARK: - Settings View

struct SettingsView: View {
    @EnvironmentObject var viewModel: WorkoutViewModel
    @State private var notificationsEnabled = false
    @State private var reminderHour = 7
    @State private var reminderMinute = 0
    @State private var showResetAlert = false

    private let hours = Array(5...22)

    var body: some View {
        NavigationStack {
            List {
                // MARK: - Notifications
                Section {
                    Toggle(isOn: $notificationsEnabled) {
                        Label("Lembretes de treino", systemImage: "bell.badge")
                    }
                    .tint(AppTheme.primary)
                    .onChange(of: notificationsEnabled) { _, newValue in
                        handleNotificationToggle(newValue)
                    }

                    if notificationsEnabled {
                        Picker(selection: $reminderHour) {
                            ForEach(hours, id: \.self) { hour in
                                Text(String(format: "%02d:00", hour)).tag(hour)
                            }
                        } label: {
                            Label("Horário", systemImage: "clock")
                        }
                        .onChange(of: reminderHour) { _, _ in
                            scheduleReminders()
                        }
                    }
                } header: {
                    Text("Notificações")
                } footer: {
                    Text("Receba um lembrete nos dias de treino (Seg–Sex).")
                }

                // MARK: - Progress
                Section {
                    HStack {
                        Label("Treinos concluídos", systemImage: "checkmark.circle")
                        Spacer()
                        Text("\(viewModel.totalWorkoutsCompleted)/\(viewModel.workouts.count)")
                            .foregroundColor(.secondary)
                    }

                    HStack {
                        Label("Progresso semanal", systemImage: "chart.bar")
                        Spacer()
                        Text("\(Int(viewModel.weeklyProgressPercent * 100))%")
                            .foregroundColor(.secondary)
                    }

                    Button(role: .destructive) {
                        showResetAlert = true
                    } label: {
                        Label("Resetar progresso da semana", systemImage: "arrow.counterclockwise")
                    }
                } header: {
                    Text("Progresso")
                }

                // MARK: - iCloud
                Section {
                    HStack {
                        Label("Backup iCloud", systemImage: "icloud.fill")
                        Spacer()
                        Text("Ativo")
                            .foregroundColor(.green)
                            .font(.caption.bold())
                    }

                    HStack {
                        Label("Sincronização", systemImage: "arrow.triangle.2.circlepath")
                        Spacer()
                        Text("Automática")
                            .foregroundColor(.secondary)
                    }
                } header: {
                    Text("iCloud")
                } footer: {
                    Text("Seus treinos e progresso são sincronizados automaticamente com o iCloud.")
                }

                // MARK: - About
                Section {
                    HStack {
                        Label("Versão", systemImage: "info.circle")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }

                    HStack {
                        Label("Feito com", systemImage: "heart.fill")
                        Spacer()
                        Text("SwiftUI + 🔥")
                            .foregroundColor(.secondary)
                    }
                } header: {
                    Text("Sobre")
                }
            }
            .navigationTitle("Configurações")
            .navigationBarTitleDisplayMode(.inline)
            .alert("Resetar Progresso", isPresented: $showResetAlert) {
                Button("Cancelar", role: .cancel) {}
                Button("Resetar", role: .destructive) {
                    viewModel.resetProgress()
                }
            } message: {
                Text("Isso vai zerar todas as séries e treinos concluídos desta semana. Essa ação não pode ser desfeita.")
            }
            .onAppear {
                checkNotificationStatus()
                healthKitEnabled = HealthKitService.shared.isAuthorized()
                if healthKitEnabled { fetchHealthData() }
            }
        }
    }

    // MARK: - Helpers

    private func handleNotificationToggle(_ enabled: Bool) {
        if enabled {
            NotificationService.shared.requestPermission { granted in
                if granted {
                    scheduleReminders()
                } else {
                    notificationsEnabled = false
                }
            }
        } else {
            NotificationService.shared.cancelAllReminders()
        }
    }

    private func scheduleReminders() {
        NotificationService.shared.scheduleWorkoutReminders(at: reminderHour, minute: reminderMinute)
        NotificationService.shared.scheduleRestDayMessage()
    }

    private func checkNotificationStatus() {
        NotificationService.shared.checkPermissionStatus { authorized in
            notificationsEnabled = authorized
        }
    }

    private func fetchHealthData() {
        HealthKitService.shared.fetchTodaySteps { steps in
            todaySteps = steps
        }
        HealthKitService.shared.fetchTodayCalories { cals in
            todayCalories = cals
        }
    }
}
