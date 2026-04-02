import SwiftUI

struct EphemerisResultView: View {
    let result: EphemerisResult

    @State private var showChart: Bool = true

    var body: some View {
        VStack(spacing: 16) {
            // Result Header
            resultHeader

            // Angular Points (geocentric only)
            if result.mode == .geocentric, let houses = result.houseCusps {
                angularSection(houses: houses)
            }

            // Chart Wheel
            if showChart {
                chartWheelSection
            }

            // Planet Positions
            planetPositionsSection

            // House Cusps (geocentric only)
            if result.mode == .geocentric, let houses = result.houseCusps {
                HouseCuspsView(houseCusps: houses)
            }
        }
    }

    // MARK: - Result Header

    private var resultHeader: some View {
        VStack(spacing: 10) {
            // Date & Location
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 8) {
                        Image(systemName: "calendar")
                            .foregroundColor(Theme.lightBlue)

                        Text(result.formattedDate)
                            .font(.system(size: 16, weight: .semibold, design: .monospaced))
                            .foregroundColor(Theme.textPrimary)
                    }

                    HStack(spacing: 8) {
                        Image(systemName: "location")
                            .foregroundColor(Theme.lightBlue)

                        Text(result.locationName)
                            .font(.system(size: 13))
                            .foregroundColor(Theme.textSecondary)
                    }
                }

                Spacer()

                // Mode badge
                Text(result.mode.rawValue)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(
                        Capsule()
                            .fill(result.mode == .geocentric ? Theme.primaryBlue : Theme.accentGold.opacity(0.8))
                    )
            }

            Divider()
                .background(Theme.cardBorder)

            // Technical data row
            HStack(spacing: 0) {
                techDataItem(label: "Día Juliano", value: result.formattedJulianDay)
                Spacer()
                techDataItem(label: "Tiempo Sidéreo", value: result.formattedSiderealTime)
                Spacer()
                techDataItem(label: "UTC", value: result.formattedUTCOffset)
            }
        }
        .cardStyle()
    }

    private func techDataItem(label: String, value: String) -> some View {
        VStack(spacing: 2) {
            Text(label)
                .font(.system(size: 10))
                .foregroundColor(Theme.textSecondary)
            Text(value)
                .font(.system(size: 12, weight: .medium, design: .monospaced))
                .foregroundColor(Theme.lightBlue)
        }
    }

    // MARK: - Angular Points Section

    private func angularSection(houses: HouseCusps) -> some View {
        VStack(spacing: 12) {
            Text("⭐ Puntos Angulares")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(Theme.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)

            // Grid of 4 angular points
            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: 10),
                GridItem(.flexible(), spacing: 10)
            ], spacing: 10) {
                angularCard(label: "ASC", subtitle: "Ascendente", value: houses.formattedAscendant, symbol: "↑", color: Theme.accentGold)
                angularCard(label: "DSC", subtitle: "Descendente", value: houses.formattedDescendant, symbol: "↓", color: Theme.accentGold)
                angularCard(label: "MC", subtitle: "Medium Coeli", value: houses.formattedMC, symbol: "⇑", color: Theme.lightBlue)
                angularCard(label: "IC", subtitle: "Imum Coeli", value: houses.formattedIC, symbol: "⇓", color: Theme.lightBlue)
            }

            // Vertex
            HStack {
                Image(systemName: "diamond")
                    .foregroundColor(Theme.textSecondary)
                Text("Vértice")
                    .font(.system(size: 13))
                    .foregroundColor(Theme.textSecondary)
                Spacer()
                Text(houses.formattedVertex)
                    .font(.system(size: 13, weight: .medium, design: .monospaced))
                    .foregroundColor(Theme.textPrimary)
            }
            .padding(.top, 4)
        }
        .cardStyle()
    }

    private func angularCard(label: String, subtitle: String, value: String, symbol: String, color: Color) -> some View {
        VStack(spacing: 6) {
            // Label badge
            HStack(spacing: 4) {
                Text(symbol)
                    .font(.system(size: 12))
                Text(label)
                    .font(.system(size: 14, weight: .bold))
            }
            .foregroundColor(color)

            // Subtitle
            Text(subtitle)
                .font(.system(size: 11))
                .foregroundColor(Theme.textSecondary)

            // Value
            Text(value)
                .font(.system(size: 15, weight: .semibold, design: .monospaced))
                .foregroundColor(Theme.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .padding(12)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(color.opacity(0.06))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(color.opacity(0.2), lineWidth: 1)
        )
    }

    // MARK: - Chart Wheel Section

    private var chartWheelSection: some View {
        VStack(spacing: 10) {
            HStack {
                Text("🔮 Rueda Astral")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(Theme.textPrimary)

                Spacer()

                Button {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        showChart.toggle()
                    }
                } label: {
                    Image(systemName: showChart ? "chevron.up" : "chevron.down")
                        .foregroundColor(Theme.textSecondary)
                }
            }

            if showChart {
                ChartWheelView(
                    planetPositions: result.planetPositions,
                    houseCusps: result.houseCusps,
                    showHouses: result.mode == .geocentric
                )
                .frame(minHeight: 300)
                .transition(.opacity.combined(with: .scale(scale: 0.95)))
            }
        }
        .cardStyle()
    }

    // MARK: - Planet Positions Section

    private var planetPositionsSection: some View {
        VStack(spacing: 10) {
            // Section header with retrograde count
            HStack {
                Text("🪐 Posiciones Planetarias")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(Theme.textPrimary)

                Spacer()

                let retrogradeCount = result.planetPositions.filter { $0.isRetrograde }.count
                if retrogradeCount > 0 {
                    Text("\(retrogradeCount) Rx")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(Theme.accentRed)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(
                            Capsule()
                                .fill(Theme.accentRed.opacity(0.15))
                        )
                }
            }

            // Column headers
            HStack(spacing: 8) {
                Text("Planeta")
                    .frame(width: 120, alignment: .leading)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(Theme.textSecondary)
                Text("Longitud")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(Theme.textSecondary)
                Text("Vel.")
                    .frame(width: 70, alignment: .trailing)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(Theme.textSecondary)
            }
            .padding(.horizontal, 12)
            .padding(.bottom, 4)

            // Planet rows
            ForEach(result.planetPositions) { position in
                PlanetRowCard(position: position)
            }
        }
        .cardStyle()
    }
}

#Preview {
    ScrollView {
        EphemerisResultView(
            result: EphemerisResult(
                date: Date(),
                utcOffset: 0,
                locationName: "Greenwich, Londres",
                latitude: 51.5074,
                longitude: -0.1278,
                mode: .geocentric,
                julianDay: 2460000.5,
                siderealTime: 12.5,
                obliquity: 23.44,
                planetPositions: [
                    PlanetPosition(planet: .sun, longitude: 45.5, latitude: 0.2, distance: 1.0, longitudeSpeed: 0.956, rightAscension: 45.0, declination: 10.5, isRetrograde: false),
                    PlanetPosition(planet: .moon, longitude: 120.3, latitude: 5.1, distance: 0.00257, longitudeSpeed: 13.2, rightAscension: 120.0, declination: 20.0, isRetrograde: false),
                    PlanetPosition(planet: .mercury, longitude: 210.8, latitude: -2.0, distance: 0.8, longitudeSpeed: -1.234, rightAscension: 210.0, declination: -5.3, isRetrograde: true),
                    PlanetPosition(planet: .venus, longitude: 300.1, latitude: 3.5, distance: 0.7, longitudeSpeed: 0.8, rightAscension: 300.0, declination: 15.0, isRetrograde: false),
                    PlanetPosition(planet: .mars, longitude: 60.7, latitude: 1.5, distance: 1.5, longitudeSpeed: 0.5, rightAscension: 60.0, declination: 22.0, isRetrograde: false)
                ],
                houseCusps: HouseCusps(
                    ascendant: 45.0,
                    descendant: 225.0,
                    mediumCoeli: 90.0,
                    imumCoeli: 270.0,
                    vertex: 180.0,
                    equatorialAscendant: 47.0,
                    houseCusps: [0.0, 45.0, 75.0, 90.0, 120.0, 150.0, 225.0, 255.0, 270.0, 300.0, 330.0, 15.0, 30.0]
                )
            )
        )
        .padding()
    }
    .background(Theme.background)
    .preferredColorScheme(.dark)
}
