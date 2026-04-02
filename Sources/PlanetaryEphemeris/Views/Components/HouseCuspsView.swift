import SwiftUI

struct HouseCuspsView: View {
    let houseCusps: HouseCusps

    // MARK: - House Categories
    private var angularHouses: [Int] { [1, 4, 7, 10] }
    private var succedentHouses: [Int] { [2, 5, 8, 11] }
    private var cadentHouses: [Int] { [3, 6, 9, 12] }

    // MARK: - Color for House Type
    private func houseColor(_ index: Int) -> Color {
        if angularHouses.contains(index) {
            return Theme.accentGold
        } else if succedentHouses.contains(index) {
            return Theme.primaryBlue
        } else {
            return Theme.textSecondary
        }
    }

    private func houseTypeName(_ index: Int) -> String {
        if angularHouses.contains(index) {
            return "Angular"
        } else if succedentHouses.contains(index) {
            return "Sucedente"
        } else {
            return "Cadente"
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Section header
            HStack {
                Text("🏠 Cuspides de las Casas")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(Theme.textPrimary)

                Spacer()

                // Legend
                HStack(spacing: 10) {
                    legendDot(color: Theme.accentGold, label: "Angular")
                    legendDot(color: Theme.primaryBlue, label: "Sucedente")
                    legendDot(color: Theme.textSecondary, label: "Cadente")
                }
                .font(.system(size: 10))
            }

            // Angular Houses (prominent)
            VStack(alignment: .leading, spacing: 4) {
                Text("Casas Angulares")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(Theme.accentGold)

                LazyVGrid(columns: [
                    GridItem(.flexible(), spacing: 8),
                    GridItem(.flexible(), spacing: 8)
                ], spacing: 8) {
                    ForEach(angularHouses, id: \.self) { index in
                        CuspCard(index: index, cuspText: houseCusps.formattedCusp(index), color: houseColor(index))
                    }
                }
            }

            // Succedent Houses
            VStack(alignment: .leading, spacing: 4) {
                Text("Casas Sucedentes")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(Theme.primaryBlue)

                LazyVGrid(columns: [
                    GridItem(.flexible(), spacing: 8),
                    GridItem(.flexible(), spacing: 8)
                ], spacing: 8) {
                    ForEach(succedentHouses, id: \.self) { index in
                        CuspCard(index: index, cuspText: houseCusps.formattedCusp(index), color: houseColor(index))
                    }
                }
            }

            // Cadent Houses
            VStack(alignment: .leading, spacing: 4) {
                Text("Casas Cadentes")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(Theme.textSecondary)

                LazyVGrid(columns: [
                    GridItem(.flexible(), spacing: 8),
                    GridItem(.flexible(), spacing: 8)
                ], spacing: 8) {
                    ForEach(cadentHouses, id: \.self) { index in
                        CuspCard(index: index, cuspText: houseCusps.formattedCusp(index), color: houseColor(index))
                    }
                }
            }
        }
        .cardStyle()
    }

    // MARK: - Legend Dot

    private func legendDot(color: Color, label: String) -> some View {
        HStack(spacing: 3) {
            Circle()
                .fill(color)
                .frame(width: 6, height: 6)
            Text(label)
                .foregroundColor(Theme.textSecondary)
        }
    }
}

// MARK: - Cusp Card Component

private struct CuspCard: View {
    let index: Int
    let cuspText: String
    let color: Color

    private var houseName: String {
        switch index {
        case 1: return "I"
        case 2: return "II"
        case 3: return "III"
        case 4: return "IV"
        case 5: return "V"
        case 6: return "VI"
        case 7: return "VII"
        case 8: return "VIII"
        case 9: return "IX"
        case 10: return "X"
        case 11: return "XI"
        case 12: return "XII"
        default: return ""
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            // House number badge
            HStack(spacing: 6) {
                Text("Casa \(index)")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(color)

                Text(houseName)
                    .font(.system(size: 11))
                    .foregroundColor(Theme.textSecondary)
            }

            // Cusp degree value
            Text(cuspText)
                .font(.system(size: 13, weight: .medium, design: .monospaced))
                .foregroundColor(Theme.textPrimary)
        }
        .padding(10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(hex: "0A0E1A").opacity(0.5))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(color.opacity(0.2), lineWidth: 1)
        )
    }
}

#Preview {
    HouseCuspsView(
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
    .padding()
    .background(Theme.background)
    .preferredColorScheme(.dark)
}
