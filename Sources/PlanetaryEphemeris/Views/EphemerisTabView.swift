import SwiftUI

struct EphemerisTabView: View {
    // MARK: - Date State
    @State private var day: Int = 1
    @State private var month: Int = 1
    @State private var year: Int = 2024
    @State private var hour: Int = 0
    @State private var minute: Int = 0

    // MARK: - Settings State
    @State private var utcOffset: Double = 0
    @State private var mode: EphemerisMode = .geocentric
    @State private var houseSystem: HouseSystem = .placidus

    // MARK: - Location (default: Greenwich)
    @State private var latitude: Double = 51.5074
    @State private var longitude: Double = -0.1278
    @State private var locationName: String = "Greenwich, Londres"

    // MARK: - Result State
    @State private var result: EphemerisResult? = nil
    @State private var isCalculating: Bool = false
    @State private var showError: Bool = false
    @State private var errorMessage: String = ""

    // MARK: - Computed Date
    private var selectedDate: Date {
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = day
        components.hour = hour
        components.minute = minute
        components.second = 0
        components.timeZone = TimeZone(secondsFromGMT: Int(utcOffset * 3600))
        return Calendar(identifier: .gregorian).date(from: components) ?? Date()
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    // Title
                    headerView

                    // Date Picker Section
                    datePickerSection

                    // UTC Offset Section
                    utcOffsetSection

                    // Location Section
                    locationSection

                    // Mode & House System Section
                    modeSection

                    // Calculate Button
                    calculateButton

                    // Results
                    if let result = result {
                        EphemerisResultView(result: result)
                            .transition(.opacity.combined(with: .move(edge: .bottom)))
                    }

                    Spacer(minLength: 40)
                }
                .padding(.horizontal)
            }
            .background(Theme.background)
            .navigationTitle("🔮 Efemérides")
            .navigationBarTitleDisplayMode(.inline)
        }
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorMessage)
        }
    }

    // MARK: - Header View

    private var headerView: some View {
        VStack(spacing: 4) {
            Text("Efemérides Planetarias")
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(Theme.textPrimary)
            Text("Cálculos astronómicos con Swiss Ephemeris")
                .subtitleStyle()
        }
        .padding(.top, 8)
    }

    // MARK: - Date Picker Section

    private var datePickerSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionLabel("📅 Fecha")

            HStack(spacing: 6) {
                // Day picker
                pickerView(title: "Día", range: 1...31, selection: $day)

                // Month picker
                pickerView(title: "Mes", range: 1...12, selection: $month)

                // Year picker
                pickerView(title: "Año", range: 1800...2200, selection: $year)
            }

            HStack(spacing: 6) {
                // Hour picker
                pickerView(title: "Hora", range: 0...23, selection: $hour)

                // Minute picker
                pickerView(title: "Min", range: 0...59, selection: $minute)
            }
        }
        .cardStyle()
    }

    // MARK: - Picker View Helper

    @ViewBuilder
    private func pickerView<T: Hashable & Strideable>(title: String, range: ClosedRange<T>, selection: Binding<T>) -> some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(Theme.textSecondary)

            Picker(title, selection: selection) {
                ForEach(Array(stride(from: range.lowerBound, to: range.upperBound + 1, by: 1)), id: \.self) { value in
                    Text("\(value)").tag(value)
                }
            }
            .pickerStyle(.wheel)
            .frame(maxWidth: .infinity)
            .clipped()
        }
        .padding(.vertical, 4)
    }

    // MARK: - UTC Offset Section

    private var utcOffsetSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionLabel("🌐 Huso Horario")

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

    // MARK: - Location Section

    private var locationSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionLabel("📍 Ubicación")

            VStack(alignment: .leading, spacing: 4) {
                Text(locationName)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(Theme.textPrimary)

                let latDir = latitude >= 0 ? "N" : "S"
                let lonDir = longitude >= 0 ? "E" : "W"
                Text(String(format: "%.4f°%@, %.4f°%@", abs(latitude), latDir, abs(longitude), lonDir))
                    .subtitleStyle()
            }
        }
        .cardStyle()
    }

    // MARK: - Mode & House System Section

    private var modeSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Mode Picker
            sectionLabel("🔭 Modo de Cálculo")

            Picker("Modo", selection: $mode) {
                ForEach(EphemerisMode.allCases) { m in
                    VStack {
                        Text(m.rawValue)
                            .foregroundColor(Theme.textPrimary)
                        Text(m.description)
                            .font(.system(size: 11))
                            .foregroundColor(Theme.textSecondary)
                    }
                    .tag(m)
                }
            }
            .pickerStyle(.segmented)
            .padding(.vertical, 4)

            // House System Picker (only for geocentric)
            if mode == .geocentric {
                Divider()
                    .background(Theme.cardBorder)
                    .padding(.vertical, 6)

                HStack {
                    Text("🏠 Sistema de Casas")
                        .font(.system(size: 14))
                        .foregroundColor(Theme.textSecondary)

                    Spacer()

                    Picker("Casas", selection: $houseSystem) {
                        ForEach(HouseSystem.allCases) { system in
                            Text(system.rawValue).tag(system)
                        }
                    }
                    .pickerStyle(.menu)
                    .tint(Theme.lightBlue)
                    .foregroundColor(Theme.textPrimary)
                }
            }
        }
        .cardStyle()
    }

    // MARK: - Calculate Button

    private var calculateButton: some View {
        Button(action: calculateEphemeris) {
            HStack {
                if isCalculating {
                    ProgressView()
                        .tint(.white)
                        .scaleEffect(0.8)
                } else {
                    Image(systemName: "sparkles")
                    Text("CALCULAR EFEMÉRIDES")
                        .fontWeight(.bold)
                }
            }
            .font(.system(size: 16))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isCalculating ? Theme.lightBlue : Theme.primaryBlue)
                    .shadow(color: Theme.primaryBlue.opacity(0.3), radius: 8, x: 0, y: 4)
            )
        }
        .disabled(isCalculating)
        .padding(.top, 4)
    }

    // MARK: - Section Label Helper

    private func sectionLabel(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 14, weight: .semibold))
            .foregroundColor(Theme.textSecondary)
    }

    // MARK: - Calculate

    private func calculateEphemeris() {
        isCalculating = true

        // Validate date
        let calendar = Calendar(identifier: .gregorian)
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = day
        components.hour = hour
        components.minute = minute
        components.timeZone = TimeZone(secondsFromGMT: Int(utcOffset * 3600))

        guard calendar.date(from: components) != nil else {
            errorMessage = "Fecha inválida. Por favor verifica los valores."
            showError = true
            isCalculating = false
            return
        }

        // Run calculation on background thread
        DispatchQueue.global(qos: .userInitiated).async {
            let ephemerisResult = SwissEphemerisService.shared.calculateEphemeris(
                date: selectedDate,
                utcOffset: utcOffset,
                latitude: latitude,
                longitude: longitude,
                locationName: locationName,
                mode: mode,
                houseSystem: houseSystem
            )

            DispatchQueue.main.async {
                self.result = ephemerisResult
                self.isCalculating = false
            }
        }
    }
}

#Preview {
    EphemerisTabView()
        .preferredColorScheme(.dark)
}
