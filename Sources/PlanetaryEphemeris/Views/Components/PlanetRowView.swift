import SwiftUI

struct PlanetRowView: View {
    let position: PlanetPosition
    @State private var isExpanded: Bool = false

    var body: some View {
        DisclosureGroup(isExpanded: $isExpanded) {
            // Detailed data section
            VStack(alignment: .leading, spacing: 8) {
                detailRow(label: "Latitud", value: position.formattedLatitude)
                detailRow(label: "Ascensión Recta", value: position.formattedRA)
                detailRow(label: "Declinación", value: position.formattedDeclination)
                detailRow(label: "Distancia", value: position.formattedDistance)
                detailRow(label: "Velocidad", value: position.formattedSpeed)
            }
            .padding(.horizontal, 4)
            .padding(.top, 6)
        } label: {
            // Main planet row
            HStack(spacing: 12) {
                // Planet symbol with colored circle background
                ZStack {
                    Circle()
                        .fill(Color(hex: position.planet.hexColor).opacity(0.15))
                        .frame(width: 40, height: 40)

                    Text(position.planet.symbol)
                        .font(.system(size: 20))
                        .foregroundColor(Color(hex: position.planet.hexColor))
                }

                // Planet name and retrograde
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 6) {
                        Text(position.planet.name)
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(Theme.textPrimary)

                        if position.isRetrograde {
                            Text("Rx")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(Theme.accentRed)
                                .padding(.horizontal, 5)
                                .padding(.vertical, 1)
                                .background(
                                    Capsule()
                                        .fill(Theme.accentRed.opacity(0.15))
                                )
                        }
                    }

                    // Position with sign
                    Text(position.formattedWithSign)
                        .font(.system(size: 13))
                        .foregroundColor(Theme.textSecondary)
                }

                Spacer()

                // Speed indicator
                VStack(alignment: .trailing, spacing: 2) {
                    HStack(spacing: 3) {
                        Image(systemName: position.longitudeSpeed >= 0 ? "arrow.up.right" : "arrow.down.left")
                            .font(.system(size: 10))
                            .foregroundColor(position.longitudeSpeed >= 0 ? Theme.accentGreen : Theme.accentRed)

                        Text(String(format: "%+.4f°/d", position.longitudeSpeed))
                            .font(.system(size: 11))
                            .foregroundColor(position.longitudeSpeed >= 0 ? Theme.accentGreen : Theme.accentRed)
                    }
                }
            }
            .padding(.vertical, 4)
        }
        .tint(Theme.primaryBlue)
    }

    // MARK: - Detail Row Helper

    private func detailRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(.system(size: 13))
                .foregroundColor(Theme.textSecondary)
                .frame(width: 120, alignment: .leading)

            Text(value)
                .font(.system(size: 13, weight: .medium, design: .monospaced))
                .foregroundColor(Theme.textPrimary)

            Spacer()
        }
    }
}

// MARK: - Planet Row Card (standalone card version)

struct PlanetRowCard: View {
    let position: PlanetPosition

    var body: some View {
        PlanetRowView(position: position)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Theme.card)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Theme.cardBorder, lineWidth: 0.5)
            )
    }
}

#Preview {
    VStack(spacing: 12) {
        PlanetRowCard(
            position: PlanetPosition(
                planet: .mars,
                longitude: 45.5,
                latitude: 2.3,
                distance: 1.523,
                longitudeSpeed: 0.5234,
                rightAscension: 30.0,
                declination: 12.5,
                isRetrograde: false
            )
        )
        PlanetRowCard(
            position: PlanetPosition(
                planet: .mercury,
                longitude: 210.3,
                latitude: -1.2,
                distance: 0.8,
                longitudeSpeed: -1.234,
                rightAscension: 210.0,
                declination: -5.3,
                isRetrograde: true
            )
        )
    }
    .padding()
    .background(Theme.background)
    .preferredColorScheme(.dark)
}
