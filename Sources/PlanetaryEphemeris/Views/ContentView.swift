import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            EphemerisTabView()
                .tabItem {
                    Label("Efemérides", systemImage: "star.circle.fill")
                }
                .tag(0)

            SearchTabView()
                .tabItem {
                    Label("Búsqueda", systemImage: "magnifyingglass")
                }
                .tag(1)
        }
        .preferredColorScheme(.dark)
        .tint(Color(hex: "1A6BFF"))
    }
}

// MARK: - Color Hex Extension

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Theme Constants

struct Theme {
    static let background = Color(hex: "0A0E1A")
    static let card = Color(hex: "141B2D")
    static let cardBorder = Color(hex: "1E2A45")
    static let primaryBlue = Color(hex: "1A6BFF")
    static let lightBlue = Color(hex: "4D9FFF")
    static let textPrimary = Color(hex: "E8E8E8")
    static let textSecondary = Color(hex: "8899BB")
    static let accentGold = Color(hex: "FFD700")
    static let accentRed = Color(hex: "FF4444")
    static let accentGreen = Color(hex: "44FF88")
}

// MARK: - View Extensions

extension View {
    func cardStyle() -> some View {
        self
            .padding()
            .background(Theme.card)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Theme.cardBorder, lineWidth: 1)
            )
    }

    func sectionTitle(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 18, weight: .bold))
            .foregroundColor(Theme.textPrimary)
    }

    func subtitleStyle() -> some View {
        self
            .font(.system(size: 14, weight: .regular))
            .foregroundColor(Theme.textSecondary)
    }
}

#Preview {
    ContentView()
}
