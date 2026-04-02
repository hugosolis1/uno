import Foundation

final class SwissEphemerisService {

    static let shared = SwissEphemerisService()

    private let queue = DispatchQueue(label: "com.planetaryephemeris.swisseph", attributes: .concurrent)
    private var isInitialized = false

    // Swiss Ephemeris constants
    private let SEFLG_SPEED: Int32 = 256
    private let SEFLG_EQUATORIAL: Int32 = 2
    private let SEFLG_HELCTR: Int32 = 2 << 10  // 2048
    private let SEFLG_MOSEPH: Int32 = 2 << 20  // Moshier ephemeris fallback

    private init() {}

    // MARK: - Initialize

    func initialize() {
        queue.sync(flags: .barrier) {
            guard !isInitialized else { return }

            // Find ephemeris data files path
            let ephePath: String
            if let bundlePath = Bundle.main.resourcePath {
                ephePath = bundlePath + "/ephe"
            } else {
                ephePath = ""
            }

            ephePath.withCString { cPath in
                swe_set_ephe_path(cPath)
            }

            isInitialized = true
            print("[SwissEphemeris] Initialized with ephemeris path: \(ephePath)")
        }
    }

    deinit {
        swe_close()
    }

    // MARK: - Julian Day

    func julianDay(from date: Date, utcOffset: Double) -> Double {
        let calendar = Calendar(identifier: .gregorian)
        let tz = TimeZone(secondsFromGMT: Int(utcOffset * 3600))!
        var components = calendar.dateComponents(in: tz, from: date)
        components.timeZone = tz

        let year = Int32(components.year ?? 2000)
        let month = Int32(components.month ?? 1)
        let day = Int32(components.day ?? 1)
        var hour = (components.hour ?? 0).doubleValue
        hour += (components.minute ?? 0).doubleValue / 60.0
        hour += (components.second ?? 0).doubleValue / 3600.0

        // Convert local hour to UT
        let hourUT = hour - utcOffset

        return swe_julday(year, month, day, hourUT, 1)
    }

    // MARK: - Planet Positions

    func calculatePlanets(julianDay: Double, mode: EphemerisMode) -> [PlanetPosition] {
        initialize()

        var flags: Int32 = SEFLG_SPEED | SEFLG_EQUATORIAL | SEFLG_MOSEPH
        if mode == .heliocentric {
            flags |= SEFLG_HELCTR
        }

        var positions: [PlanetPosition] = []

        for planet in PlanetType.allCases {
            let pos = calculatePlanet(Int32(planet.rawValue), jd: julianDay, flags: flags)
            if let pos = pos {
                positions.append(pos)
            }
        }

        return positions
    }

    private func calculatePlanet(_ planet: Int32, jd: Double, flags: Int32) -> PlanetPosition? {
        var xx = [Double](repeating: 0.0, count: 6)
        var serr = [CChar](repeating: 0, count: 256)

        let result = swe_calc_ut(jd, planet, flags, &xx, &serr)

        guard result >= 0 else {
            let error = String(cString: serr)
            print("[SwissEphemeris] Error calculating planet \(planet): \(error)")
            return nil
        }

        guard let planetType = PlanetType(rawValue: Int(planet)) else { return nil }

        let longitude = xx[0]
        let latitude = xx[1]
        let distance = xx[2]
        let longitudeSpeed = xx[3]

        let isRetrograde = longitudeSpeed < 0

        // Calculate approximate RA and Declination from ecliptic coordinates
        let obliquity = obliquityOfEcliptic(jd: jd)
        let (ra, dec) = eclipticToEquatorial(longitude: longitude, latitude: latitude, obliquity: obliquity)

        return PlanetPosition(
            planet: planetType,
            longitude: longitude,
            latitude: latitude,
            distance: distance,
            longitudeSpeed: longitudeSpeed,
            rightAscension: ra,
            declination: dec,
            isRetrograde: isRetrograde
        )
    }

    // MARK: - House Cusps

    func calculateHouses(julianDay: Double, latitude: Double, longitude: Double, system: HouseSystem = .placidus) -> HouseCusps? {
        initialize()

        var cusps = [Double](repeating: 0.0, count: 13) // cusps[0] unused, 1-12
        var ascmc = [Double](repeating: 0.0, count: 10)

        let Int32(hsys) = system.letter

        let result = swe_houses(julianDay, latitude, longitude, Int32(hsys), &cusps, &ascmc)

        guard result >= 0 else {
            print("[SwissEphemeris] Error calculating houses")
            return nil
        }

        // Extract house cusps (skip index 0)
        let houseCusps = Array(cusps[1...12])

        // ascmc positions
        let ascendant = ascmc[0]
        let mc = ascmc[1]
        let vertex = ascmc[3]
        let eqAsc = ascmc[4]  // equatorial ascendant

        // IC is opposite of MC
        let ic = normalizeDegrees(mc + 180)
        // Descendant is opposite of Ascendant
        let descendant = normalizeDegrees(ascendant + 180)

        return HouseCusps(
            ascendant: ascendant,
            descendant: descendant,
            mediumCoeli: mc,
            imumCoeli: ic,
            vertex: vertex,
            equatorialAscendant: eqAsc,
            houseCusps: houseCusps
        )
    }

    // MARK: - Sidereal Time

    func siderealTime(julianDay: Double) -> Double {
        return swe_sidtime(julianDay)
    }

    // MARK: - Obliquity

    func obliquityOfEcliptic(jd: Double) -> Double {
        // Using a simplified but accurate formula for obliquity
        let T = (jd - 2451545.0) / 36525.0
        let eps0 = 23.0 + 26.0/60.0 + 21.448/3600.0
            - (46.8150*T + 0.00059*T*T - 0.001813*T*T*T) / 3600.0
        return eps0
    }

    // MARK: - Coordinate Conversion

    private func eclipticToEquatorial(longitude: Double, latitude: Double, obliquity: Double) -> (ra: Double, dec: Double) {
        let epsRad = obliquity * .pi / 180.0
        let lonRad = longitude * .pi / 180.0
        let latRad = latitude * .pi / 180.0

        let sinDec = sin(latRad) * cos(epsRad) + cos(latRad) * sin(epsRad) * sin(lonRad)
        let dec = asin(sinDec) * 180.0 / .pi

        let y = sin(lonRad) * cos(epsRad) - tan(latRad) * sin(epsRad)
        let x = cos(lonRad)
        let ra = atan2(y, x) * 180.0 / .pi

        let normalizedRA = normalizeDegrees(ra)
        return (normalizedRA, dec)
    }

    // MARK: - Full Ephemeris Calculation

    func calculateEphemeris(
        date: Date,
        utcOffset: Double,
        latitude: Double,
        longitude: Double,
        locationName: String,
        mode: EphemerisMode,
        houseSystem: HouseSystem = .placidus
    ) -> EphemerisResult {
        initialize()

        let jd = julianDay(from: date, utcOffset: utcOffset)
        let st = siderealTime(julianDay: jd)
        let obliquity = obliquityOfEcliptic(jd: jd)

        let planetPositions = calculatePlanets(julianDay: jd, mode: mode)

        // Houses only meaningful for geocentric
        var houseCusps: HouseCusps? = nil
        if mode == .geocentric {
            houseCusps = calculateHouses(julianDay: jd, latitude: latitude, longitude: longitude, system: houseSystem)
        }

        return EphemerisResult(
            date: date,
            utcOffset: utcOffset,
            locationName: locationName,
            latitude: latitude,
            longitude: longitude,
            mode: mode,
            julianDay: jd,
            siderealTime: st,
            obliquity: obliquity,
            planetPositions: planetPositions,
            houseCusps: houseCusps
        )
    }
}

// MARK: - Int extension for DoubleValue
extension Int {
    var doubleValue: Double {
        return Double(self)
    }
}


// MARK: - Helper Functions

func normalizeDegrees(_ degrees: Double) -> Double {
    let result = degrees.truncatingRemainder(dividingBy: 360)
    return result < 0 ? result + 360 : result
}
