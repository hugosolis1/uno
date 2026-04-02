import Foundation

final class DegreeSearchService {

    private let ephemerisService = SwissEphemerisService.shared
    private let queue = DispatchQueue(label: "com.planetaryephemeris.search", qos: .userInitiated)

    // MARK: - Search

    func searchDegree(params: DegreeSearchParams, progress: @escaping (Double) -> Void) -> [DegreeSearchMatch] {
        var matches: [DegreeSearchMatch] = []

        let calendar = Calendar(identifier: .gregorian)
        let utc = TimeZone(secondsFromGMT: Int(params.utcOffset * 3600))!

        let startComponents = calendar.dateComponents(in: utc, from: params.startDate)
        let endComponents = calendar.dateComponents(in: utc, from: params.endDate)

        let startJD = ephemerisService.julianDay(from: params.startDate, utcOffset: params.utcOffset)
        let endJD = ephemerisService.julianDay(from: params.endDate, utcOffset: params.utcOffset)

        // Determine step size based on date range
        let totalDays = endJD - startJD
        let stepDays: Double

        if totalDays <= 1 {
            stepDays = 0.01  // ~15 minutes for short ranges
        } else if totalDays <= 30 {
            stepDays = 0.04  // ~1 hour
        } else if totalDays <= 365 {
            stepDays = 0.25  // ~6 hours
        } else if totalDays <= 3650 {
            stepDays = 1.0   // 1 day
        } else {
            stepDays = 2.0   // 2 days
        }

        var currentJD = startJD
        var previousPositions: [Int32: Double] = [:]

        while currentJD <= endJD {
            let progressValue = (currentJD - startJD) / (endJD - startJD)
            progress(progressValue)

            for planet in params.selectedPlanets {
                let planetConstant = planet.swissephConstant

                // Calculate position
                let flags: Int32 = 256 | 2 | (2 << 20)  // SPEED | EQUATORIAL | MOSEPH
                var xx = [Double](repeating: 0.0, count: 6)
                var serr = [CChar](repeating: 0, count: 256)

                let result = swe_calc_ut(currentJD, planetConstant, flags, &xx, &serr)
                guard result >= 0 else { continue }

                let longitude = xx[0]
                let speed = xx[3]
                let isRetrograde = speed < 0

                // Check if planet crossed the target degree
                if let prevLon = previousPositions[planetConstant] {
                    let normalizedTarget = ((params.targetDegree % 360) + 360) % 360

                    // Detect crossing
                    let crossed = detectCrossing(previous: prevLon, current: longitude, target: normalizedTarget)

                    if crossed || abs(longitudeDifference(longitude, normalizedTarget)) < params.tolerance {
                        // Convert JD back to Date (UT)
                        let date = dateFromJulianDay(currentJD)

                        let sign = ZodiacSign.fromDegrees(longitude)
                        let degreeInSign = ZodiacSign.positionInSign(longitude)
                        let isExact = abs(longitudeDifference(longitude, normalizedTarget)) < params.tolerance

                        let match = DegreeSearchMatch(
                            planet: planet,
                            date: date,
                            longitude: longitude,
                            sign: sign,
                            degreeInSign: degreeInSign,
                            isRetrograde: isRetrograde,
                            isExact: isExact
                        )
                        matches.append(match)
                    }
                }

                previousPositions[planetConstant] = longitude
            }

            currentJD += stepDays
        }

        // Sort by date
        matches.sort { $0.date < $1.date }

        return matches
    }

    // MARK: - Helpers

    private func detectCrossing(previous: Double, current: Double, target: Double) -> Bool {
        let prevNorm = ((previous % 360) + 360) % 360
        let currNorm = ((current % 360) + 360) % 360
        let targetNorm = ((target % 360) + 360) % 360

        // Check if target is between previous and current
        if prevNorm <= currNorm {
            return targetNorm >= prevNorm && targetNorm <= currNorm
        } else {
            // Wrapped around 360
            return targetNorm >= prevNorm || targetNorm <= currNorm
        }
    }

    private func longitudeDifference(_ lon1: Double, _ lon2: Double) -> Double {
        let diff = ((lon1 - lon2 + 180) % 360) - 180
        return ((diff + 180) % 360) - 180
    }

    private func dateFromJulianDay(_ jd: Double) -> Date {
        var year: Int32 = 0
        var month: Int32 = 0
        var day: Int32 = 0
        var hour: Double = 0

        swe_revjul(jd, 1, &year, &month, &day, &hour)

        let calendar = Calendar(identifier: .gregorian)
        var components = DateComponents()
        components.year = Int(year)
        components.month = Int(month)
        components.day = Int(day)
        components.hour = Int(hour)
        components.minute = Int((hour - Double(Int(hour))) * 60)
        components.second = Int(((hour - Double(Int(hour))) * 60 - Double(Int((hour - Double(Int(hour))) * 60))) * 60)
        components.timeZone = TimeZone(secondsFromGMT: 0)

        return calendar.date(from: components) ?? Date()
    }
}
