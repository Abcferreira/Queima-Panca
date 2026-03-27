import SwiftUI
import SwiftData

// MARK: - Custom Workouts List View

struct CustomWorkoutsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \CustomWorkout.createdAt) private var customWorkouts: [CustomWorkout]
    @State private var showingCreateSheet = false
    @State private var workoutToEdit: CustomWorkout?
    @State private var workoutToDelete: CustomWorkout?

    var body: some View {
        NavigationStack {
            Group {
                if customWorkouts.isEmpty {
                    emptyState
                } else {
                    workoutsList
                }
            }
            .navigationTitle("Meus Treinos")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingCreateSheet = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(AppTheme.primary)
                            .font(.title3)
                    }
                }
            }
            .sheet(isPresented: $showingCreateSheet) {
                CreateWorkoutView()
            }
            .sheet(item: $workoutToEdit) { workout in
                CreateWorkoutView(editingWorkout: workout)
            }
            .alert("Excluir Treino", isPresented: .init(
                get: { workoutToDelete != nil },
                set: { if !$0 { workoutToDelete = nil } }
            )) {
                Button("Cancelar", role: .cancel) { workoutToDelete = nil }
                Button("Excluir", role: .destructive) {
                    if let workout = workoutToDelete {
                        modelContext.delete(workout)
                        try? modelContext.save()
                    }
                }
            } message: {
                Text("Tem certeza que deseja excluir este treino? Essa ação não pode ser desfeita.")
            }
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 20) {
            Spacer()

            Image(systemName: "dumbbell.fill")
                .font(.system(size: 60))
                .foregroundColor(AppTheme.primary.opacity(0.3))

            VStack(spacing: 8) {
                Text("Nenhum treino customizado")
                    .font(.title3.bold())
                Text("Crie seu próprio treino personalizado\ncom exercícios do catálogo")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }

            Button {
                showingCreateSheet = true
            } label: {
                HStack {
                    Image(systemName: "plus")
                    Text("Criar Primeiro Treino")
                }
                .primaryButton()
            }
            .padding(.horizontal, 40)

            Spacer()
        }
        .padding()
    }

    // MARK: - Workouts List

    private var workoutsList: some View {
        ScrollView {
            VStack(spacing: 12) {
                ForEach(customWorkouts) { workout in
                    customWorkoutCard(workout)
                }

                // Add new button
                Button {
                    showingCreateSheet = true
                } label: {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("Novo Treino")
                            .font(.headline)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(AppTheme.secondary)
                    .foregroundColor(AppTheme.primary)
                    .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadius))
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 32)
        }
        .background(AppTheme.background.ignoresSafeArea())
    }

    // MARK: - Workout Card

    private func customWorkoutCard(_ workout: CustomWorkout) -> some View {
        HStack(spacing: 14) {
            // Icon
            ZStack {
                Circle()
                    .fill(AppTheme.secondary)
                    .frame(width: 52, height: 52)

                Image(systemName: "figure.strengthtraining.traditional")
                    .font(.title3)
                    .foregroundColor(AppTheme.primary)
            }

            // Info
            VStack(alignment: .leading, spacing: 4) {
                Text(workout.name)
                    .font(.headline)
                    .lineLimit(1)

                Text(workout.day)
                    .font(.caption)
                    .foregroundColor(.secondary)

                HStack(spacing: 12) {
                    Label("\(workout.exercises.count) exercícios", systemImage: "dumbbell")
                    Label("\(workout.estimatedMinutes) min", systemImage: "clock")
                }
                .font(.caption2)
                .foregroundColor(.secondary)
            }

            Spacer()

            // Actions
            Menu {
                Button {
                    workoutToEdit = workout
                } label: {
                    Label("Editar", systemImage: "pencil")
                }

                Button(role: .destructive) {
                    workoutToDelete = workout
                } label: {
                    Label("Excluir", systemImage: "trash")
                }
            } label: {
                Image(systemName: "ellipsis.circle")
                    .font(.title3)
                    .foregroundColor(.secondary)
            }
        }
        .fitnessCard()
    }
}

// MARK: - Create / Edit Workout View

struct CreateWorkoutView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    // Edit mode
    var editingWorkout: CustomWorkout?

    @State private var workoutName = ""
    @State private var selectedDay = "Segunda-feira"
    @State private var cardio = ""
    @State private var estimatedMinutes = 60
    @State private var selectedExercises: [SelectedExercise] = []
    @State private var showingExercisePicker = false

    private let days = ["Segunda-feira", "Terça-feira", "Quarta-feira", "Quinta-feira", "Sexta-feira", "Sábado", "Domingo"]

    private var isValid: Bool {
        !workoutName.trimmingCharacters(in: .whitespaces).isEmpty && !selectedExercises.isEmpty
    }

    var body: some View {
        NavigationStack {
            Form {
                // MARK: - Info Section
                Section("Informações") {
                    TextField("Nome do treino", text: $workoutName)

                    Picker("Dia", selection: $selectedDay) {
                        ForEach(days, id: \.self) { day in
                            Text(day).tag(day)
                        }
                    }

                    Stepper("Duração: \(estimatedMinutes) min", value: $estimatedMinutes, in: 15...180, step: 5)

                    TextField("Cardio (opcional)", text: $cardio)
                }

                // MARK: - Exercises Section
                Section {
                    if selectedExercises.isEmpty {
                        HStack {
                            Spacer()
                            VStack(spacing: 8) {
                                Image(systemName: "plus.circle.dashed")
                                    .font(.largeTitle)
                                    .foregroundColor(.secondary.opacity(0.5))
                                Text("Adicione exercícios")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.vertical, 20)
                            Spacer()
                        }
                    } else {
                        ForEach($selectedExercises) { $exercise in
                            exerciseRow(exercise: $exercise)
                        }
                        .onDelete(perform: deleteExercise)
                        .onMove(perform: moveExercise)
                    }

                    Button {
                        showingExercisePicker = true
                    } label: {
                        Label("Adicionar Exercício", systemImage: "plus.circle.fill")
                            .foregroundColor(AppTheme.primary)
                    }
                } header: {
                    HStack {
                        Text("Exercícios (\(selectedExercises.count))")
                        Spacer()
                        if !selectedExercises.isEmpty {
                            EditButton()
                                .font(.caption)
                        }
                    }
                }
            }
            .navigationTitle(editingWorkout == nil ? "Novo Treino" : "Editar Treino")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancelar") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Salvar") { save() }
                        .bold()
                        .disabled(!isValid)
                }
            }
            .sheet(isPresented: $showingExercisePicker) {
                ExercisePickerView(selectedExercises: $selectedExercises)
            }
            .onAppear { loadEditingWorkout() }
        }
    }

    // MARK: - Exercise Row

    private func exerciseRow(exercise: Binding<SelectedExercise>) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: exercise.wrappedValue.muscleGroup.icon)
                    .foregroundColor(AppTheme.primary)
                    .frame(width: 24)

                Text(exercise.wrappedValue.name)
                    .font(.subheadline.bold())
                    .lineLimit(1)

                Spacer()

                Text(exercise.wrappedValue.muscleGroup.rawValue)
                    .font(.caption2)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(AppTheme.secondary)
                    .foregroundColor(AppTheme.primary)
                    .clipShape(Capsule())
            }

            HStack(spacing: 16) {
                // Sets
                HStack(spacing: 4) {
                    Text("Séries:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Stepper("\(exercise.wrappedValue.setsCount)", value: exercise.setsCount, in: 1...10)
                        .font(.caption.bold())
                }

                Divider().frame(height: 20)

                // Reps
                HStack(spacing: 4) {
                    Text("Reps:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    TextField("12", text: exercise.repsOrDuration)
                        .font(.caption.bold())
                        .frame(width: 40)
                        .textFieldStyle(.roundedBorder)
                }

                Divider().frame(height: 20)

                // Weight
                HStack(spacing: 4) {
                    Text("Peso:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    TextField("0", value: exercise.weight, format: .number)
                        .font(.caption.bold())
                        .frame(width: 45)
                        .textFieldStyle(.roundedBorder)
                        .keyboardType(.decimalPad)
                    Text("kg")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.vertical, 4)
    }

    // MARK: - Actions

    private func deleteExercise(at offsets: IndexSet) {
        selectedExercises.remove(atOffsets: offsets)
    }

    private func moveExercise(from source: IndexSet, to destination: Int) {
        selectedExercises.move(fromOffsets: source, toOffset: destination)
    }

    private func save() {
        if let workout = editingWorkout {
            // Update existing
            workout.name = workoutName
            workout.day = selectedDay
            workout.cardio = cardio
            workout.estimatedMinutes = estimatedMinutes

            // Clear and re-add exercises
            workout.exercises.removeAll()
            for (index, ex) in selectedExercises.enumerated() {
                let custom = CustomExercise(
                    name: ex.name,
                    muscleGroup: ex.muscleGroup,
                    setsCount: ex.setsCount,
                    repsOrDuration: ex.repsOrDuration,
                    weight: ex.weight,
                    videoURL: ex.videoURL,
                    order: index
                )
                workout.exercises.append(custom)
            }
        } else {
            // Create new
            let workout = CustomWorkout(
                name: workoutName,
                day: selectedDay,
                cardio: cardio,
                estimatedMinutes: estimatedMinutes
            )
            for (index, ex) in selectedExercises.enumerated() {
                let custom = CustomExercise(
                    name: ex.name,
                    muscleGroup: ex.muscleGroup,
                    setsCount: ex.setsCount,
                    repsOrDuration: ex.repsOrDuration,
                    weight: ex.weight,
                    videoURL: ex.videoURL,
                    order: index
                )
                workout.exercises.append(custom)
            }
            modelContext.insert(workout)
        }

        try? modelContext.save()
        dismiss()
    }

    private func loadEditingWorkout() {
        guard let workout = editingWorkout else { return }
        workoutName = workout.name
        selectedDay = workout.day
        cardio = workout.cardio
        estimatedMinutes = workout.estimatedMinutes
        selectedExercises = workout.exercises
            .sorted { $0.order < $1.order }
            .map { ex in
                SelectedExercise(
                    name: ex.name,
                    muscleGroup: ex.muscleGroup,
                    setsCount: ex.setsCount,
                    repsOrDuration: ex.repsOrDuration,
                    weight: ex.weight,
                    videoURL: ex.videoURL
                )
            }
    }
}

// MARK: - Selected Exercise (transient model for the form)

struct SelectedExercise: Identifiable {
    let id = UUID()
    let name: String
    let muscleGroup: MuscleGroup
    var setsCount: Int
    var repsOrDuration: String
    var weight: Double
    var videoURL: String
}

// MARK: - Exercise Picker View

struct ExercisePickerView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedExercises: [SelectedExercise]
    @State private var searchText = ""
    @State private var selectedGroup: MuscleGroup?
    @State private var pickedExercises: Set<String> = []

    private var filteredExercises: [CatalogExercise] {
        var list: [CatalogExercise]
        if let group = selectedGroup {
            list = ExerciseCatalog.exercises(for: group)
        } else {
            list = ExerciseCatalog.all
        }

        if !searchText.isEmpty {
            list = list.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }

        return list
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Muscle Group Filter
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        filterChip(title: "Todos", icon: "list.bullet", isSelected: selectedGroup == nil) {
                            selectedGroup = nil
                        }

                        ForEach(MuscleGroup.allCases) { group in
                            filterChip(
                                title: group.rawValue,
                                icon: group.icon,
                                isSelected: selectedGroup == group
                            ) {
                                selectedGroup = group
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                }

                // List
                List {
                    ForEach(filteredExercises) { exercise in
                        exercisePickerRow(exercise)
                    }
                }
                .listStyle(.plain)
            }
            .searchable(text: $searchText, prompt: "Buscar exercício...")
            .navigationTitle("Escolher Exercícios")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancelar") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Adicionar (\(pickedExercises.count))") {
                        addPickedExercises()
                        dismiss()
                    }
                    .bold()
                    .disabled(pickedExercises.isEmpty)
                }
            }
            .onAppear {
                pickedExercises = Set(selectedExercises.map(\.name))
            }
        }
    }

    // MARK: - Filter Chip

    private func filterChip(title: String, icon: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.caption2)
                Text(title)
                    .font(.caption.bold())
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(isSelected ? AppTheme.primary : AppTheme.secondary)
            .foregroundColor(isSelected ? .white : AppTheme.primary)
            .clipShape(Capsule())
        }
    }

    // MARK: - Exercise Row

    private func exercisePickerRow(_ exercise: CatalogExercise) -> some View {
        Button {
            toggleExercise(exercise)
        } label: {
            HStack(spacing: 12) {
                Image(systemName: pickedExercises.contains(exercise.name)
                      ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(pickedExercises.contains(exercise.name)
                                     ? AppTheme.primary : .gray.opacity(0.4))
                    .font(.title3)

                VStack(alignment: .leading, spacing: 2) {
                    Text(exercise.name)
                        .font(.subheadline.bold())
                        .foregroundColor(.primary)

                    HStack(spacing: 8) {
                        Label(exercise.muscleGroup.rawValue, systemImage: exercise.muscleGroup.icon)
                        Text("·")
                        Text("\(exercise.defaultSets)x\(exercise.defaultReps)")
                    }
                    .font(.caption)
                    .foregroundColor(.secondary)
                }

                Spacer()
            }
        }
    }

    // MARK: - Helpers

    private func toggleExercise(_ exercise: CatalogExercise) {
        if pickedExercises.contains(exercise.name) {
            pickedExercises.remove(exercise.name)
        } else {
            pickedExercises.insert(exercise.name)
        }
    }

    private func addPickedExercises() {
        let existingNames = Set(selectedExercises.map(\.name))

        // Add new picks
        for exercise in ExerciseCatalog.all where pickedExercises.contains(exercise.name) && !existingNames.contains(exercise.name) {
            selectedExercises.append(
                SelectedExercise(
                    name: exercise.name,
                    muscleGroup: exercise.muscleGroup,
                    setsCount: exercise.defaultSets,
                    repsOrDuration: exercise.defaultReps,
                    weight: 0,
                    videoURL: exercise.videoURL
                )
            )
        }

        // Remove deselected
        selectedExercises.removeAll { !pickedExercises.contains($0.name) }
    }
}
