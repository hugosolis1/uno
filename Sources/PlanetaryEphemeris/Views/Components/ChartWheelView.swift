import SwiftUI

// MARK: - Helper Functions

func normalizeDegrees(_ degrees: Double) -> Double {
    let result = degrees.truncatingRemainder(dividingBy: 360)
    return result < 0 ? result + 360 : result
}

func normalizeDegreesCGFloat(_ degrees: Double) -> CGFloat {
    return CGFloat(normalizeDegrees(degrees))
}

private func drawText(_ context: inout GraphicsContext, text: Text, at point: CGPoint) {
    context.draw(text, at: point)
}


struct ChartWheelView: View {
    let planetPositions: [PlanetPosition]
    let houseCusps: HouseCusps?
    let showHouses: Bool

    var body: some View {
        GeometryReader { geometry in
            Canvas { context, size in
                drawWheel(context: &context, size: size)
            }
        }
        .aspectRatio(1, contentMode: .fit)
        .background(
            Circle()
                .fill(Color(hex: "060A14"))
        )
        .clipShape(Circle())
    }

    // MARK: - Draw Wheel

    private func drawWheel(context: inout GraphicsContext, size: CGSize) {
        let center = CGPoint(x: size.width / 2, y: size.height / 2)
        let maxRadius = min(size.width, size.height) / 2

        // Define ring radii
        let zodiacOuterRadius = maxRadius * 0.95
        let zodiacInnerRadius = maxRadius * 0.78
        let houseOuterRadius = maxRadius * 0.76
        let houseInnerRadius = maxRadius * 0.55
        let planetRadius = maxRadius * 0.65
        let innerRadius = maxRadius * 0.15

        // MARK: Draw background circle
        let bgCircle = Path { path in
            path.addEllipse(in: CGRect(x: center.x - zodiacOuterRadius, y: center.y - zodiacOuterRadius,
                                        width: zodiacOuterRadius * 2, height: zodiacOuterRadius * 2))
        }
        context.fill(bgCircle, with: .color(Color(hex: "0A0E1A")))

        // MARK: Draw zodiac ring
        drawZodiacRing(context: &context, center: center, innerRadius: zodiacInnerRadius, outerRadius: zodiacOuterRadius)

        // MARK: Draw outer circle border
        drawCircle(context: &context, center: center, radius: zodiacOuterRadius, color: Color(hex: "2A3A5A"), lineWidth: 1.5)
        drawCircle(context: &context, center: center, radius: zodiacInnerRadius, color: Color(hex: "2A3A5A"), lineWidth: 1.0)

        // MARK: Draw house divisions
        if showHouses, let houses = houseCusps {
            drawHouseLines(context: &context, center: center, innerRadius: innerRadius, outerRadius: zodiacInnerRadius, houses: houses)

            // Draw inner circle for house area
            drawCircle(context: &context, center: center, radius: houseInnerRadius, color: Color(hex: "1A2240"), lineWidth: 0.5)
        }

        // MARK: Draw ASC and MC lines
        if let houses = houseCusps {
            drawAngularLine(context: &context, center: center, degrees: houses.ascendantDegrees, radius: zodiacInnerRadius, color: Theme.accentGold, lineWidth: 2.0, label: "ASC")
            drawAngularLine(context: &context, center: center, degrees: houses.mcDegrees, radius: zodiacInnerRadius, color: Theme.accentGold, lineWidth: 2.0, label: "MC")
        }

        // MARK: Draw planet symbols
        drawPlanets(context: &context, center: center, radius: planetRadius, outerRadius: zodiacInnerRadius)

        // MARK: Draw center dot
        let centerDot = Path { path in
            path.addEllipse(in: CGRect(x: center.x - 3, y: center.y - 3, width: 6, height: 6))
        }
        context.fill(centerDot, with: .color(Theme.primaryBlue))
    }

    // MARK: - Zodiac Ring

    private func drawZodiacRing(context: inout GraphicsContext, center: CGPoint, innerRadius: CGFloat, outerRadius: CGFloat) {
        let zodiacSigns = ZodiacSign.allCases

        for (index, sign) in zodiacSigns.enumerated() {
            let startAngle = Angle.degrees(Double(index) * 30.0) - 90
            let endAngle = Angle.degrees(Double(index + 1) * 30.0) - 90

            // Alternate zodiac segment colors
            let segmentColor = index % 2 == 0 ? Color(hex: "0E1425") : Color(hex: "111830")

            // Draw filled arc segment
            let segmentPath = Path { path in
                path.move(to: CGPoint(
                    x: center.x + innerRadius * cos(startAngle.radians),
                    y: center.y + innerRadius * sin(startAngle.radians)
                ))

                path.addArc(center: center, radius: outerRadius, startAngle: startAngle, endAngle: endAngle, clockwise: false)
                path.addArc(center: center, radius: innerRadius, startAngle: endAngle, endAngle: startAngle, clockwise: true)
                path.closeSubpath()
            }
            context.fill(segmentPath, with: .color(segmentColor))

            // Draw dividing lines between signs
            let linePath = Path { path in
                path.move(to: CGPoint(
                    x: center.x + innerRadius * cos(startAngle.radians),
                    y: center.y + innerRadius * sin(startAngle.radians)
                ))
                path.addLine(to: CGPoint(
                    x: center.x + outerRadius * cos(startAngle.radians),
                    y: center.y + outerRadius * sin(startAngle.radians)
                ))
            }
            context.stroke(linePath, with: .color(Color(hex: "2A3A5A")), lineWidth: 0.5)

            // Draw sign symbol
            let midAngle = Angle.degrees(Double(index) * 30.0 + 15.0) - 90
            let symbolRadius = (innerRadius + outerRadius) / 2
            let symbolX = center.x + symbolRadius * cos(midAngle.radians)
            let symbolY = center.y + symbolRadius * sin(midAngle.radians)

            let textPoint = CGPoint(x: symbolX, y: symbolY)
            let signText = Text(sign.symbol)
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(Theme.textPrimary)

            drawText(&context, text: signText, at: textPoint)
        }
    }

    // MARK: - House Lines

    private func drawHouseLines(context: inout GraphicsContext, center: CGPoint, innerRadius: CGFloat, outerRadius: CGFloat, houses: HouseCusps) {
        for index in 1...12 {
            let cuspWithZero = [0.0] + houses.houseCusps
            guard index < cuspWithZero.count else { continue }

            let degrees = normalizeDegrees(cuspWithZero[index])
            let angle = Angle.degrees(degrees) - 90

            // Thicker lines for angular houses
            let isAngular = [1, 4, 7, 10].contains(index)
            let lineWidth: CGFloat = isAngular ? 1.5 : 0.7
            let lineColor = isAngular ? Theme.accentGold.opacity(0.6) : Color(hex: "2A3A5A")

            let linePath = Path { path in
                path.move(to: CGPoint(
                    x: center.x + innerRadius * cos(angle.radians),
                    y: center.y + innerRadius * sin(angle.radians)
                ))
                path.addLine(to: CGPoint(
                    x: center.x + outerRadius * cos(angle.radians),
                    y: center.y + outerRadius * sin(angle.radians)
                ))
            }
            context.stroke(linePath, with: .color(lineColor), lineWidth: lineWidth)

            // House number labels inside
            if index < 12 {
                let nextIndex = index + 1
                let nextDegrees = normalizeDegrees(cuspWithZero[nextIndex])
                let midDegrees = ((degrees + nextDegrees) / 2.0).truncatingRemainder(dividingBy: 360)
                let midAngle = Angle.degrees(midDegrees) - 90
                let labelRadius = innerRadius + (outerRadius - innerRadius) * 0.35
                let labelX = center.x + labelRadius * cos(midAngle.radians)
                let labelY = center.y + labelRadius * sin(midAngle.radians)

                let houseNum = Text("\(index)")
                    .font(.system(size: 9))
                    .foregroundColor(isAngular ? Theme.accentGold.opacity(0.7) : Theme.textSecondary.opacity(0.6))

                drawText(&context, text: houseNum, at: CGPoint(x: labelX, y: labelY))
            }
        }
    }

    // MARK: - Angular Lines (ASC, MC)

    private func drawAngularLine(context: inout GraphicsContext, center: CGPoint, degrees: Double, radius: CGFloat, color: Color, lineWidth: CGFloat, label: String) {
        let angle = Angle.degrees(degrees) - 90

        // Extend line from center to the zodiac ring edge
        let linePath = Path { path in
            path.move(to: CGPoint(
                x: center.x + 0 * cos(angle.radians),
                y: center.y + 0 * sin(angle.radians)
            ))
            path.addLine(to: CGPoint(
                x: center.x + radius * cos(angle.radians),
                y: center.y + radius * sin(angle.radians)
            ))
        }
        context.stroke(linePath, with: .color(color.opacity(0.8)), lineWidth: lineWidth)

        // Label
        let labelRadius = radius + 12
        let labelX = center.x + labelRadius * cos(angle.radians)
        let labelY = center.y + labelRadius * sin(angle.radians)

        let labelText = Text(label)
            .font(.system(size: 10, weight: .bold))
            .foregroundColor(color)

        drawText(&context, text: labelText, at: CGPoint(x: labelX, y: labelY))
    }

    // MARK: - Planet Symbols

    private func drawPlanets(context: inout GraphicsContext, center: CGPoint, radius: CGFloat, outerRadius: CGFloat) {
        // Track planet symbol positions to avoid overlaps
        var placedPositions: [CGPoint] = []

        for position in planetPositions {
            let degrees = normalizeDegrees(position.longitude)
            let angle = Angle.degrees(degrees) - 90

            var pointX = center.x + radius * cos(angle.radians)
            var pointY = center.y + radius * sin(angle.radians)

            // Simple collision avoidance
            let minDistance: CGFloat = 18
            var adjusted = false
            for _ in 0..<3 {
                var collision = false
                for placed in placedPositions {
                    let dx = pointX - placed.x
                    let dy = pointY - placed.y
                    let dist = sqrt(dx * dx + dy * dy)
                    if dist < minDistance {
                        collision = true
                        // Push slightly outward
                        pointX += (pointX - center.x) * 0.08
                        pointY += (pointY - center.y) * 0.08
                        break
                    }
                }
                adjusted = collision
                if !collision { break }
            }

            // Keep within bounds
            let distFromCenter = sqrt(pow(pointX - center.x, 2) + pow(pointY - center.y, 2))
            if distFromCenter > outerRadius - 10 {
                let scale = (outerRadius - 10) / distFromCenter
                pointX = center.x + (pointX - center.x) * scale
                pointY = center.y + (pointY - center.y) * scale
            }

            placedPositions.append(CGPoint(x: pointX, y: pointY))

            let planetColor = Color(hex: position.planet.hexColor)

            // Draw planet background circle
            let bgPath = Path { path in
                path.addEllipse(in: CGRect(x: pointX - 10, y: pointY - 10, width: 20, height: 20))
            }
            context.fill(bgPath, with: .color(Color(hex: "0A0E1A").opacity(0.85)))
            context.stroke(bgPath, with: .color(planetColor.opacity(0.5)), lineWidth: 1)

            // Draw planet symbol
            var symbolString = position.planet.symbol
            if position.isRetrograde {
                symbolString += "℞"
            }

            let symbolText = Text(symbolString)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(planetColor)

            drawText(&context, text: symbolText, at: CGPoint(x: pointX, y: pointY))
        }
    }

    // MARK: - Draw Circle Helper

    private func drawCircle(context: inout GraphicsContext, center: CGPoint, radius: CGFloat, color: Color, lineWidth: CGFloat) {
        let circlePath = Path { path in
            path.addEllipse(in: CGRect(x: center.x - radius, y: center.y - radius,
                                        width: radius * 2, height: radius * 2))
        }
        context.stroke(circlePath, with: .color(color), lineWidth: lineWidth)
    }
}

#Preview {
    VStack {
        ChartWheelView(
            planetPositions: [
                PlanetPosition(planet: .sun, longitude: 45.0, latitude: 0, distance: 1.0, longitudeSpeed: 1.0, rightAscension: 45.0, declination: 10.0, isRetrograde: false),
                PlanetPosition(planet: .moon, longitude: 120.0, latitude: 5.0, distance: 0.00257, longitudeSpeed: 13.0, rightAscension: 120.0, declination: 20.0, isRetrograde: false),
                PlanetPosition(planet: .mercury, longitude: 210.0, latitude: -2.0, distance: 0.8, longitudeSpeed: -1.2, rightAscension: 210.0, declination: -5.0, isRetrograde: true),
                PlanetPosition(planet: .venus, longitude: 300.0, latitude: 3.0, distance: 0.7, longitudeSpeed: 0.8, rightAscension: 300.0, declination: 15.0, isRetrograde: false),
                PlanetPosition(planet: .mars, longitude: 60.0, latitude: 1.5, distance: 1.5, longitudeSpeed: 0.5, rightAscension: 60.0, declination: 22.0, isRetrograde: false)
            ],
            houseCusps: HouseCusps(
                ascendant: 45.0,
                descendant: 225.0,
                mediumCoeli: 90.0,
                imumCoeli: 270.0,
                vertex: 180.0,
                equatorialAscendant: 47.0,
                houseCusps: [0.0, 45.0, 75.0, 90.0, 120.0, 150.0, 225.0, 255.0, 270.0, 300.0, 330.0, 15.0, 30.0]
            ),
            showHouses: true
        )
        .frame(width: 350, height: 350)
        .padding()
    }
    .background(Theme.background)
    .preferredColorScheme(.dark)
}
