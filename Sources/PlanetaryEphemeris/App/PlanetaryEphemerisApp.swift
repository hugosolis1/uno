import SwiftUI

@main
struct PlanetaryEphemerisApp: App {
    init() {
        // Initialize Swiss Ephemeris
        SwissEphemerisService.shared.initialize()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.dark)
        }
    }
}
