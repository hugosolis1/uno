import Foundation
import UIKit

// MARK: - Planet Types

enum PlanetType: Int, CaseIterable, Identifiable {
    case sun = 0
    case moon = 1
    case mercury = 2
    case venus = 3
    case mars = 4
    case jupiter = 5
    case saturn = 6
    case uranus = 7
    case neptune = 8
    case pluto = 9
    case northNode = 10

    var id: Int { rawValue }

    var name: String {
        switch self {
        case .sun: return "Sol"
        case .moon: return "Luna"
        case .mercury: return "Mercurio"
        case .venus: return "Venus"
        case .mars: return "Marte"
        case .jupiter: return "Júpiter"
        case .saturn: return "Saturno"
        case .uranus: return "Urano"
        case .neptune: return "Neptuno"
        case .pluto: return "Plutón"
        case .northNode: return "Nodo Norte"
        }
    }

    var symbol: String {
        switch self {
        case .sun: return "☉"
        case .moon: return "☽"
        case .mercury: return "☿"
        case .venus: return "♀"
        case .mars: return "♂"
        case .jupiter: return "♃"
        case .saturn: return "♄"
        case .uranus: return "♅"
        case .neptune: return "♆"
        case .pluto: return "♇"
        case .northNode: return "☊"
        }
    }

    var color: UIColor {
        switch self {
        case .sun: return UIColor(red: 1.0, green: 0.84, blue: 0.0, alpha: 1.0)
        case .moon: return UIColor(red: 0.75, green: 0.75, blue: 0.85, alpha: 1.0)
        case .mercury: return UIColor(red: 0.63, green: 0.32, blue: 0.18, alpha: 1.0)
        case .venus: return UIColor(red: 1.0, green: 0.41, blue: 0.71, alpha: 1.0)
        case .mars: return UIColor(red: 1.0, green: 0.27, blue: 0.0, alpha: 1.0)
        case .jupiter: return UIColor(red: 0.85, green: 0.65, blue: 0.13, alpha: 1.0)
        case .saturn: return UIColor(red: 0.96, green: 0.64, blue: 0.38, alpha: 1.0)
        case .uranus: return UIColor(red: 0.25, green: 0.88, blue: 0.82, alpha: 1.0)
        case .neptune: return UIColor(red: 0.25, green: 0.41, blue: 0.88, alpha: 1.0)
        case .pluto: return UIColor(red: 0.55, green: 0.27, blue: 0.07, alpha: 1.0)
        case .northNode: return UIColor(red: 0.58, green: 0.44, blue: 0.86, alpha: 1.0)
        }
    }

    var hexColor: String {
        switch self {
        case .sun: return "#FFD700"
        case .moon: return "#BFBFDB"
        case .mercury: return "#A15230"
        case .venus: return "#FF69B4"
        case .mars: return "#FF4500"
        case .jupiter: return "#D9A621"
        case .saturn: return "#F5A361"
        case .uranus: return "#40E0D0"
        case .neptune: return "#4169E1"
        case .pluto: return "#8C4500"
        case .northNode: return "#9370DB"
        }
    }

    var swissephConstant: Int32 { Int32(rawValue) }
}

// MARK: - Zodiac Signs

enum ZodiacSign: Int, CaseIterable {
    case aries = 0
    case taurus = 1
    case gemini = 2
    case cancer = 3
    case leo = 4
    case virgo = 5
    case libra = 6
    case scorpio = 7
    case sagittarius = 8
    case capricorn = 9
    case aquarius = 10
    case pisces = 11

    var name: String {
        switch self {
        case .aries: return "Aries"
        case .taurus: return "Tauro"
        case .gemini: return "Géminis"
        case .cancer: return "Cáncer"
        case .leo: return "Leo"
        case .virgo: return "Virgo"
        case .libra: return "Libra"
        case .scorpio: return "Escorpio"
        case .sagittarius: return "Sagitario"
        case .capricorn: return "Capricornio"
        case .aquarius: return "Acuario"
        case .pisces: return "Piscis"
        }
    }

    var symbol: String {
        switch self {
        case .aries: return "♈"
        case .taurus: return "♉"
        case .gemini: return "♊"
        case .cancer: return "♋"
        case .leo: return "♌"
        case .virgo: return "♍"
        case .libra: return "♎"
        case .scorpio: return "♏"
        case .sagittarius: return "♐"
        case .capricorn: return "♑"
        case .aquarius: return "♒"
        case .pisces: return "♓"
        }
    }

    var element: String {
        switch self {
        case .aries, .leo, .sagittarius: return "Fuego"
        case .taurus, .virgo, .capricorn: return "Tierra"
        case .gemini, .libra, .aquarius: return "Aire"
        case .cancer, .scorpio, .pisces: return "Agua"
        }
    }

    static func fromDegrees(_ degrees: Double) -> ZodiacSign {
        let normalized = ((degrees % 360) + 360) % 360
        let index = Int(normalized / 30) % 12
        return ZodiacSign(rawValue: index) ?? .aries
    }

    static func positionInSign(_ degrees: Double) -> Double {
        let normalized = ((degrees % 360) + 360) % 360
        return normalized - Double(Int(normalized / 30)) * 30
    }
}

// MARK: - Planet Position

struct PlanetPosition: Identifiable {
    let id = UUID()
    let planet: PlanetType
    let longitude: Double
    let latitude: Double
    let distance: Double
    let longitudeSpeed: Double
    let rightAscension: Double
    let declination: Double
    let isRetrograde: Bool

    var sign: ZodiacSign { ZodiacSign.fromDegrees(longitude) }
    var degreeInSign: Double { ZodiacSign.positionInSign(longitude) }

    var formattedLongitude: String {
        formatDMS(longitude, withSign: true)
    }

    var formattedWithSign: String {
        let dms = formatDMS(longitude, withSign: false)
        return "\(dms) \(sign.symbol)"
    }

    var formattedLatitude: String {
        formatDMS(latitude, withSign: false)
    }

    var formattedRA: String {
        let normalized = ((rightAscension % 360) + 360) % 360
        let hours = normalized / 15.0
        let h = Int(hours)
        let minutes = (hours - Double(h)) * 60
        let m = Int(minutes)
        let seconds = (minutes - Double(m)) * 60
        return String(format: "%dh %dm %.1fs", h, m, seconds)
    }

    var formattedDeclination: String {
        let sign = declination >= 0 ? "+" : "-"
        let absDec = abs(declination)
        let d = Int(absDec)
        let minutes = (absDec - Double(d)) * 60
        let m = Int(minutes)
        let seconds = (minutes - Double(m)) * 60
        return String(format: "%@%d° %d' %.1f\"", sign, d, m, seconds)
    }

    var formattedDistance: String {
        if planet == .moon {
            return String(format: "%.2f ER", distance / 0.00257) // Earth radii approx
        }
        return String(format: "%.6f AU", distance)
    }

    var formattedSpeed: String {
        let sign = longitudeSpeed >= 0 ? "+" : ""
        return String(format: "%@%.4f °/día", sign, longitudeSpeed)
    }

    var retrogradeText: String {
        isRetrograde ? "℞" : ""
    }

    private func formatDMS(_ degrees: Double, withSign: Bool) -> String {
        let normalized = ((degrees % 360) + 360) % 360
        let d = Int(normalized)
        let minutes = (normalized - Double(d)) * 60
        let m = Int(minutes)
        let seconds = (minutes - Double(m)) * 60
        return String(format: "%d° %d' %.1f\"", d, m, seconds)
    }
}

// MARK: - House System

enum HouseSystem: String, CaseIterable, Identifiable {
    case placidus = "Placidus"
    case koch = "Koch"
    case porphyry = "Porfirio"
    case equal = "Igual"
    case wholeSign = "Signo Entero"

    var id: String { rawValue }
    var letter: CChar {
        switch self {
        case .placidus: return CChar(UnicodeScalar("P").value)
        case .koch: return CChar(UnicodeScalar("K").value)
        case .porphyry: return CChar(UnicodeScalar("O").value)
        case .equal: return CChar(UnicodeScalar("E").value)
        case .wholeSign: return CChar(UnicodeScalar("W").value)
        }
    }
}

// MARK: - House Cusps

struct HouseCusps {
    let ascendant: Double
    let descendant: Double
    let mediumCoeli: Double
    let imumCoeli: Double
    let vertex: Double
    let equatorialAscendant: Double
    let houseCusps: [Double]  // cusps[1] to cusps[12]

    var ascendantSign: ZodiacSign { ZodiacSign.fromDegrees(ascendant) }
    var mcSign: ZodiacSign { ZodiacSign.fromDegrees(mediumCoeli) }
    var descendantSign: ZodiacSign { ZodiacSign.fromDegrees(descendant) }
    var icSign: ZodiacSign { ZodiacSign.fromDegrees(imumCoeli) }

    var formattedAscendant: String { formatDegreesWithSign(ascendant) }
    var formattedMC: String { formatDegreesWithSign(mediumCoeli) }
    var formattedDescendant: String { formatDegreesWithSign(descendant) }
    var formattedIC: String { formatDegreesWithSign(imumCoeli) }
    var formattedVertex: String { formatDegreesWithSign(vertex) }

    var ascendantDegrees: Double {
        ((ascendant % 360) + 360) % 360
    }

    var mcDegrees: Double {
        ((mediumCoeli % 360) + 360) % 360
    }

    func formattedCusp(_ index: Int) -> String {
        guard index >= 1 && index <= 12 else { return "---" }
        let cuspsWithZero = [0.0] + houseCusps
        return formatDegreesWithSign(cuspsWithZero[index])
    }

    private func formatDegreesWithSign(_ deg: Double) -> String {
        let normalized = ((deg % 360) + 360) % 360
        let sign = ZodiacSign.fromDegrees(normalized)
        let d = Int(normalized)
        let minutes = (normalized - Double(d)) * 60
        let m = Int(minutes)
        let seconds = (minutes - Double(m)) * 60
        return String(format: "%d° %d' %.1f\" %@", d, m, seconds, sign.symbol)
    }
}

// MARK: - Ephemeris Mode

enum EphemerisMode: String, CaseIterable, Identifiable {
    case geocentric = "Geocéntrico"
    case heliocentric = "Heliocéntrico"
    var id: String { rawValue }
    var description: String {
        switch self {
        case .geocentric: return "Visto desde la Tierra"
        case .heliocentric: return "Visto desde el Sol"
        }
    }
}

// MARK: - Ephemeris Result

struct EphemerisResult {
    let date: Date
    let utcOffset: Double
    let locationName: String
    let latitude: Double
    let longitude: Double
    let mode: EphemerisMode
    let julianDay: Double
    let siderealTime: Double
    let obliquity: Double
    let planetPositions: [PlanetPosition]
    let houseCusps: HouseCusps?

    var formattedJulianDay: String {
        String(format: "JD %.6f", julianDay)
    }

    var formattedSiderealTime: String {
        let st = ((siderealTime % 24) + 24) % 24
        let hours = Int(st)
        let minutesF = (st - Double(hours)) * 60
        let minutes = Int(minutesF)
        let seconds = (minutesF - Double(minutes)) * 60
        return String(format: "%dh %dm %.2fs", hours, minutes, seconds)
    }

    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy HH:mm:ss"
        formatter.timeZone = TimeZone(secondsFromGMT: Int(utcOffset * 3600))
        return formatter.string(from: date)
    }

    var formattedUTCOffset: String {
        let sign = utcOffset >= 0 ? "+" : ""
        return String(format: "UTC%@%.0f", sign, utcOffset)
    }
}

// MARK: - Degree Search Result

struct DegreeSearchMatch: Identifiable {
    let id = UUID()
    let planet: PlanetType
    let date: Date
    let longitude: Double
    let sign: ZodiacSign
    let degreeInSign: Double
    let isRetrograde: Bool
    let isExact: Bool  // true if within 1 degree of target

    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy HH:mm"
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter.string(from: date)
    }

    var formattedPosition: String {
        let normalized = ((longitude % 360) + 360) % 360
        let d = Int(normalized)
        let minutes = (normalized - Double(d)) * 60
        let m = Int(minutes)
        let seconds = (minutes - Double(m)) * 60
        let rx = isRetrograde ? " ℞" : ""
        return String(format: "%d° %d' %.1f\" %@ %@%@", d, m, seconds, sign.symbol, sign.name, rx)
    }
}

struct DegreeSearchParams {
    var startDate: Date
    var endDate: Date
    var targetDegree: Double  // 0-360
    var selectedPlanets: Set<PlanetType>
    var tolerance: Double = 1.0  // degrees tolerance for "exact" match
    var utcOffset: Double = 0.0
}
