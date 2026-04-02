import SwiftUI

struct SearchTabView: View {
    // MARK: - Date State
    @State private var startDate = Date()
    @State private var endDate = Date()

    // MARK: - Search Parameters
    @State private var targetDegree: Double = 0
    @State private var selectedPlanets: Set<PlanetType> = Set(PlanetType.allCases)
    @State private var tolerance: Double = 1.0
    @State private var utcOffset: Double = 0

    // MARK: - Results State
    @State private var matches: [DegreeSearchMatch] = []
    @State private var isSearching: Bool = false
    @State private var searchProgress: Double = 0
    @State private var hasSearched: Bool = false

    // MARK: - Tolerance Options
    private let toleranceOptions: [(label: String, value: Double)] = [
        ("0.5°", 0.5),
        ("1°", 1.0),
        ("2°", 2.0),
        ("5°", 5.0)
    ]

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    // Title
                    headerView

                    // Date Range Section
                    dateRangeSection

                    // Target Degree Section
                    targetDegreeSection

                    // Planet Selection Section
                    planetSelectionSection

                    // Tolerance & UTC Section
                    toleranceSection

                    // Search Button
                    searchButton

                    // Progress Bar
                    if isSearching {
                        progressView
                    }

                    // Results Section
                    if hasSearched && !isSearching {
                        resultsSection
                    }

                    Spacer(minLength: 40)
                }
                .padding(.horizontal)
            }
            .background(Theme.background)
            .navigationTitle("🔍 Búsqueda")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    // MARK: - Header View

    private var headerView: some View {
        VStack(spacing: 4) {
            Text("Búsqueda por Grado")
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(Theme.textPrimary)
            Text("Encuentra cuando los planetas alcanzan un grado específico")
                .subtitleStyle()
        }
        .padding(.top, 8)
    }

    // MARK: - Date Range Section

    private var dateRangeSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionLabel("📅 Rango de Fechas")

            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Desde")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(Theme.textSecondary)
                    DatePicker("", selection: $startDate, displayedComponents: [.date])
                        .labelsHidden()
                        .datePickerStyle(.compact)
                        .environment(\.locale, Locale(identifier: "es"))
                        .colorScheme(.dark)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    Text("Hasta")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(Theme.textSecondary)
                    DatePicker("", selection: $endDate, displayedComponents: [.date])
                        .labelsHidden()
                        .datePickerStyle(.compact)
                        .environment(\.locale, Locale(identifier: "es"))
                        .colorScheme(.dark)
                }
            }
        }
        .cardStyle()
    }

    // MARK: - Target Degree Section

    private var targetDegreeSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionLabel("🎯 Grado Objetivo")

            // Degree display
            HStack {
                let sign = ZodiacSign.fromDegrees(targetDegree)
                let degreeInSign = ZodiacSign.positionInSign(targetDegree)

                Text("\(sign.symbol) \(sign.name)")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(Theme.accentGold)

                Spacer()

                Text(String(format: "%.1f°", targetDegree))
                    .font(.system(size: 16, weight: .medium, design: .monospaced))
                    .foregroundColor(Theme.lightBlue)

                Text(String(format: "(%.1f° en signo)", degreeInSign))
                    .font(.system(size: 12))
                    .foregroundColor(Theme.textSecondary)
            }

            // Slider
            HStack {
                Text("0°")
                    .font(.system(size: 11))
                    .foregroundColor(Theme.textSecondary)

                Slider(value: $targetDegree, in: 0...359.9, step: 0.1)
                    .tint(Theme.primaryBlue)

                Text("360°")
                    .font(.system(size: 11))
                    .foregroundColor(Theme.textSecondary)
            }

            // Quick degree buttons for cardinal points
            HStack(spacing: 8) {
                quickDegreeButton(degree: 0, label: "♈ 0°")
                quickDegreeButton(degree: 90, label: "♋ 90°")
                quickDegreeButton(degree: 180, label: "♎ 180°")
                quickDegreeButton(degree: 270, label: "♑ 270°")
            }
        }
        .cardStyle()
    }

    private func quickDegreeButton(degree: Double, label: String) -> some View {
        Button {
            targetDegree = degree
        } label: {
            Text(label)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(abs(targetDegree - degree) < 1 ? .white : Theme.textSecondary)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(
                    Capsule()
                        .fill(abs(targetDegree - degree) < 1 ? Theme.primaryBlue : Theme.cardBorder)
                )
        }
    }

    // MARK: - Planet Selection Section

    private var planetSelectionSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                sectionLabel("🪐 Planetas")

                Spacer()

                // Select All / Deselect All
                HStack(spacing: 8) {
                    Button {
                        selectedPlanets = Set(PlanetType.allCases)
                    } label: {
                        Text("Todos")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(selectedPlanets.count == PlanetType.allCases.count ? .white : Theme.textSecondary)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(
                                Capsule()
                                    .fill(selectedPlanets.count == PlanetType.allCases.count ? Theme.primaryBlue : Theme.cardBorder)
                            )
                    }

                    Button {
                        selectedPlanets.removeAll()
                    } label: {
                        Text("Ninguno")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(selectedPlanets.isEmpty ? .white : Theme.textSecondary)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(
                                Capsule()
                                    .fill(selectedPlanets.isEmpty ? Theme.accentRed : Theme.cardBorder)
                            )
                    }
                }
            }

            // Planet toggles in a grid
            let columns = [
                GridItem(.flexible(), spacing: 6),
                GridItem(.flexible(), spacing: 6),
                GridItem(.flexible(), spacing: 6)
            ]

            LazyVGrid(columns: columns, spacing: 6) {
                ForEach(PlanetType.allCases) { planet in
                    planetToggleButton(planet: planet)
                }
            }
        }
        .cardStyle()
    }

    private func planetToggleButton(planet: PlanetType) -> some View {
        let isSelected = selectedPlanets.contains(planet)

        return Button {
            if isSelected {
                selectedPlanets.remove(planet)
            } else {
                selectedPlanets.insert(planet)
            }
        } label: {
            HStack(spacing: 5) {
                Text(planet.symbol)
                    .font(.system(size: 13))
                    .foregroundColor(Color(hex: planet.hexColor))

                Text(planet.name)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(isSelected ? .white : Theme.textSecondary)
                    .lineLimit(1)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isSelected ? Color(hex: planet.hexColor).opacity(0.2) : Color(hex: "0A0E1A"))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isSelected ? Color(hex: planet.hexColor).opacity(0.5) : Theme.cardBorder, lineWidth: 1)
            )
        }
    }

    // MARK: - Tolerance & UTC Section

    private var toleranceSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                sectionLabel("⚙️ Configuración")
                Spacer()
            }

            // Tolerance picker
            HStack {
                Text("Tolerancia")
                    .font(.system(size: 14))
                    .foregroundColor(Theme.textSecondary)

                Spacer()

                Picker("Tolerancia", selection: $tolerance) {
                    ForEach(toleranceOptions, id: \.value) { option in
                        Text(option.label).tag(option.value)
                    }
                }
                .pickerStyle(.segmented)
                .frame(width: 220)
            }

            // UTC offset
            HStack {
                Text("UTC Offset")
                    .font(.system(size: 14))
                    .foregroundColor(Theme.textSecondary)

                Spacer()

                Picker("UTC Offset", selection: $utcOffset) {
                    ForEach(Array(stride(from: -12.0, through: 14.0, by: 1.0)), id: \.self) { offset in
                        let sign = offset >= 0 ? "+" : ""
                        Text("UTC\(sign)\(Int(offset))").tag(offset)
                    }
                }
                .pickerStyle(.menu)
                .tint(Theme.lightBlue)
                .foregroundColor(Theme.textPrimary)
            }
        }
        .cardStyle()
    }

    // MARK: - Search Button

    private var searchButton: some View {
        Button(action: performSearch) {
            HStack {
                if isSearching {
                    ProgressView()
                        .tint(.white)
                        .scaleEffect(0.8)
                } else {
                    Image(systemName: "magnifyingglass")
                    Text("BUSCAR")
                        .fontWeight(.bold)
                }
            }
            .font(.system(size: 16))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSearching || selectedPlanets.isEmpty ? Theme.textSecondary.opacity(0.3) : Theme.primaryBlue)
                    .shadow(color: selectedPlanets.isEmpty ? .clear : Theme.primaryBlue.opacity(0.3), radius: 8, x: 0, y: 4)
            )
        }
        .disabled(isSearching || selectedPlanets.isEmpty)
    }

    // MARK: - Progress View

    private var progressView: some View {
        VStack(spacing: 8) {
            Text("Buscando...")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(Theme.textSecondary)

            ProgressView(value: searchProgress)
                .tint(Theme.primaryBlue)
                .progressViewStyle(.linear)

            Text("\(Int(searchProgress * 100))%")
                .font(.system(size: 12, weight: .medium, design: .monospaced))
                .foregroundColor(Theme.lightBlue)
        }
        .cardStyle()
    }

    // MARK: - Results Section

    private var resultsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                sectionLabel("📊 Resultados")
                Spacer()

                Text("\(matches.count) coincidencia\(matches.count == 1 ? "" : "s")")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(matches.isEmpty ? Theme.textSecondary : Theme.accentGold)
            }

            if matches.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 30))
                        .foregroundColor(Theme.textSecondary.opacity(0.5))
                    Text("No se encontraron coincidencias")
                        .font(.system(size: 15))
                        .foregroundColor(Theme.textSecondary)
                    Text("Intenta ajustar la tolerancia o el rango de fechas")
                        .font(.system(size: 12))
                        .foregroundColor(Theme.textSecondary.opacity(0.7))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
            } else {
                // Results list
                ForEach(matches) { match in
                    matchRow(match: match)
                }
            }
        }
        .cardStyle()
    }

    private func matchRow(match: DegreeSearchMatch) -> some View {
        HStack(spacing: 12) {
            // Planet symbol
            ZStack {
                Circle()
                    .fill(Color(hex: match.planet.hexColor).opacity(0.15))
                    .frame(width: 36, height: 36)

                Text(match.planet.symbol)
                    .font(.system(size: 16))
                    .foregroundColor(Color(hex: match.planet.hexColor))
            }

            // Planet name and retrograde
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 5) {
                    Text(match.planet.name)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(Theme.textPrimary)

                    if match.isRetrograde {
                        Text("Rx")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(Theme.accentRed)
                            .padding(.horizontal, 4)
                            .padding(.vertical, 1)
                            .background(Capsule().fill(Theme.accentRed.opacity(0.15)))
                    }

                    if match.isExact {
                        Text("✦")
                            .font(.system(size: 12))
                            .foregroundColor(Theme.accentGold)
                    }
                }

                Text(match.formattedPosition)
                    .font(.system(size: 12))
                    .foregroundColor(Theme.textSecondary)
            }

            Spacer()

            // Date
            VStack(alignment: .trailing, spacing: 2) {
                Text(match.formattedDate)
                    .font(.system(size: 12, weight: .medium, design: .monospaced))
                    .foregroundColor(Theme.lightBlue)
            }
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 10)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(match.isExact ? Theme.accentGold.opacity(0.05) : Color.clear)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(match.isExact ? Theme.accentGold.opacity(0.2) : Theme.cardBorder.opacity(0.3), lineWidth: 0.5)
        )
    }

    // MARK: - Section Label Helper

    private func sectionLabel(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 14, weight: .semibold))
            .foregroundColor(Theme.textSecondary)
    }

    // MARK: - Perform Search

    private func performSearch() {
        guard !selectedPlanets.isEmpty else { return }
        guard startDate <= endDate else { return }

        isSearching = true
        hasSearched = true
        matches = []
        searchProgress = 0

        let params = DegreeSearchParams(
            startDate: startDate,
            endDate: endDate,
            targetDegree: targetDegree,
            selectedPlanets: selectedPlanets,
            tolerance: tolerance,
            utcOffset: utcOffset
        )

        let searchService = DegreeSearchService()

        DispatchQueue.global(qos: .userInitiated).async {
            let results = searchService.searchDegree(params: params) { progress in
                DispatchQueue.main.async {
                    self.searchProgress = min(progress, 1.0)
                }
            }

            DispatchQueue.main.async {
                self.matches = results
                self.isSearching = false
                self.searchProgress = 1.0
            }
        }
    }
}

#Preview {
    SearchTabView()
        .preferredColorScheme(.dark)
}
