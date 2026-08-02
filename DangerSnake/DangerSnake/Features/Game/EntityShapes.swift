import SwiftUI

enum EntityShapes {
    // MARK: - Apple

    static func drawApple(in rect: CGRect, fill: Color, context: inout GraphicsContext, showShieldRing: Bool) {
        let body = appleBodyPath(in: rect)
        context.fill(body, with: .color(fill))

        // Soft highlight
        let highlight = CGRect(
            x: rect.minX + rect.width * 0.22,
            y: rect.minY + rect.height * 0.22,
            width: rect.width * 0.22,
            height: rect.height * 0.28
        )
        context.fill(Path(ellipseIn: highlight), with: .color(.white.opacity(0.28)))

        // Stem
        var stem = Path()
        let cx = rect.midX
        stem.move(to: CGPoint(x: cx, y: rect.minY + rect.height * 0.22))
        stem.addLine(to: CGPoint(x: cx + rect.width * 0.04, y: rect.minY + rect.height * 0.02))
        context.stroke(stem, with: .color(Color(red: 0.35, green: 0.22, blue: 0.1)), lineWidth: max(1.5, rect.width * 0.06))

        // Leaf
        let leaf = appleLeafPath(in: rect)
        context.fill(leaf, with: .color(Color(red: 0.25, green: 0.7, blue: 0.3)))

        if showShieldRing {
            let ring = rect.insetBy(dx: -rect.width * 0.08, dy: -rect.height * 0.08)
            context.stroke(
                Path(ellipseIn: ring),
                with: .color(Color(red: 0.4, green: 0.75, blue: 1.0).opacity(0.9)),
                lineWidth: max(2, rect.width * 0.08)
            )
        }
    }

    private static func appleBodyPath(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width
        let h = rect.height
        let left = rect.minX
        let top = rect.minY

        // Classic apple silhouette: two lobes with a dent on top.
        path.move(to: CGPoint(x: left + w * 0.5, y: top + h * 0.22))
        path.addCurve(
            to: CGPoint(x: left + w * 0.08, y: top + h * 0.42),
            control1: CGPoint(x: left + w * 0.32, y: top + h * 0.12),
            control2: CGPoint(x: left + w * 0.05, y: top + h * 0.22)
        )
        path.addCurve(
            to: CGPoint(x: left + w * 0.5, y: top + h * 0.95),
            control1: CGPoint(x: left + w * 0.1, y: top + h * 0.78),
            control2: CGPoint(x: left + w * 0.28, y: top + h * 0.98)
        )
        path.addCurve(
            to: CGPoint(x: left + w * 0.92, y: top + h * 0.42),
            control1: CGPoint(x: left + w * 0.72, y: top + h * 0.98),
            control2: CGPoint(x: left + w * 0.9, y: top + h * 0.78)
        )
        path.addCurve(
            to: CGPoint(x: left + w * 0.5, y: top + h * 0.22),
            control1: CGPoint(x: left + w * 0.95, y: top + h * 0.22),
            control2: CGPoint(x: left + w * 0.68, y: top + h * 0.12)
        )
        path.closeSubpath()
        return path
    }

    private static func appleLeafPath(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width
        let h = rect.height
        let left = rect.minX
        let top = rect.minY
        path.move(to: CGPoint(x: left + w * 0.52, y: top + h * 0.14))
        path.addQuadCurve(
            to: CGPoint(x: left + w * 0.82, y: top + h * 0.02),
            control: CGPoint(x: left + w * 0.72, y: top + h * 0.2)
        )
        path.addQuadCurve(
            to: CGPoint(x: left + w * 0.52, y: top + h * 0.14),
            control: CGPoint(x: left + w * 0.7, y: top - h * 0.02)
        )
        path.closeSubpath()
        return path
    }

    // MARK: - Snake

    static func drawSnakeHead(
        in rect: CGRect,
        direction: GridPos,
        fill: Color,
        context: inout GraphicsContext
    ) {
        let path = snakeHeadPath(in: rect, direction: direction)
        context.fill(path, with: .color(fill))

        // Eyes
        let eyes = snakeEyeRects(in: rect, direction: direction)
        for eye in eyes {
            context.fill(Path(ellipseIn: eye), with: .color(.white))
            let pupil = eye.insetBy(dx: eye.width * 0.28, dy: eye.height * 0.28)
            // Offset pupil slightly toward facing direction.
            let ox = CGFloat(direction.x) * eye.width * 0.12
            let oy = CGFloat(-direction.y) * eye.height * 0.12 // grid up is +y, screen y flipped in cell layout already via rect
            let pupilRect = pupil.offsetBy(dx: ox, dy: oy)
            context.fill(Path(ellipseIn: pupilRect), with: .color(.black))
        }
    }

    static func drawSnakeBody(in rect: CGRect, fill: Color, context: inout GraphicsContext) {
        context.fill(Path(roundedRect: rect, cornerRadius: min(rect.width, rect.height) * 0.45), with: .color(fill))
    }

    static func drawSnakeTail(
        in rect: CGRect,
        towardTailFrom: GridPos,
        fill: Color,
        context: inout GraphicsContext
    ) {
        // `towardTailFrom` is direction from neck to tip (head←…←tail tip direction along body).
        let path = snakeTailPath(in: rect, tipDirection: towardTailFrom)
        context.fill(path, with: .color(fill))
    }

    private static func snakeHeadPath(in rect: CGRect, direction: GridPos) -> Path {
        var path = Path()
        let inset = rect.insetBy(dx: rect.width * 0.05, dy: rect.height * 0.05)
        let cx = inset.midX
        let cy = inset.midY
        let hw = inset.width * 0.5
        let hh = inset.height * 0.5

        // Rounded diamond / teardrop facing `direction` (grid: +y up).
        // Convert to screen: up means smaller y in our cellRect (already positioned).
        let tip: CGPoint
        let left: CGPoint
        let right: CGPoint
        let back: CGPoint

        if direction.x == 1 { // right
            tip = CGPoint(x: cx + hw, y: cy)
            left = CGPoint(x: cx - hw * 0.35, y: cy - hh)
            right = CGPoint(x: cx - hw * 0.35, y: cy + hh)
            back = CGPoint(x: cx - hw * 0.85, y: cy)
        } else if direction.x == -1 { // left
            tip = CGPoint(x: cx - hw, y: cy)
            left = CGPoint(x: cx + hw * 0.35, y: cy + hh)
            right = CGPoint(x: cx + hw * 0.35, y: cy - hh)
            back = CGPoint(x: cx + hw * 0.85, y: cy)
        } else if direction.y == 1 { // up (toward top of screen = smaller y)
            tip = CGPoint(x: cx, y: cy - hh)
            left = CGPoint(x: cx - hw, y: cy + hh * 0.35)
            right = CGPoint(x: cx + hw, y: cy + hh * 0.35)
            back = CGPoint(x: cx, y: cy + hh * 0.85)
        } else { // down
            tip = CGPoint(x: cx, y: cy + hh)
            left = CGPoint(x: cx + hw, y: cy - hh * 0.35)
            right = CGPoint(x: cx - hw, y: cy - hh * 0.35)
            back = CGPoint(x: cx, y: cy - hh * 0.85)
        }

        path.move(to: tip)
        path.addQuadCurve(to: left, control: mid(tip, left, bulge: 0.15))
        path.addQuadCurve(to: back, control: mid(left, back, bulge: 0.1))
        path.addQuadCurve(to: right, control: mid(back, right, bulge: 0.1))
        path.addQuadCurve(to: tip, control: mid(right, tip, bulge: 0.15))
        path.closeSubpath()
        return path
    }

    private static func snakeEyeRects(in rect: CGRect, direction: GridPos) -> [CGRect] {
        let s = min(rect.width, rect.height) * 0.16
        let cx = rect.midX
        let cy = rect.midY
        let spread = min(rect.width, rect.height) * 0.22
        let forward = min(rect.width, rect.height) * 0.12

        let fx = CGFloat(direction.x) * forward
        let fy = CGFloat(-direction.y) * forward

        // Perpendicular offset for left/right eye.
        let px = CGFloat(-direction.y) * spread
        let py = CGFloat(-direction.x) * spread

        let e1 = CGRect(x: cx + fx + px - s / 2, y: cy + fy + py - s / 2, width: s, height: s)
        let e2 = CGRect(x: cx + fx - px - s / 2, y: cy + fy - py - s / 2, width: s, height: s)
        return [e1, e2]
    }

    private static func snakeTailPath(in rect: CGRect, tipDirection: GridPos) -> Path {
        var path = Path()
        let inset = rect.insetBy(dx: rect.width * 0.12, dy: rect.height * 0.12)
        let cx = inset.midX
        let cy = inset.midY
        let hw = inset.width * 0.5
        let hh = inset.height * 0.5

        // Tip points away from the body along tipDirection (from previous segment to tail).
        // Screen: +x right, +y down; grid +y is up so flip y for tip.
        let tip: CGPoint
        let baseL: CGPoint
        let baseR: CGPoint

        if tipDirection.x == 1 {
            tip = CGPoint(x: cx + hw, y: cy)
            baseL = CGPoint(x: cx - hw * 0.4, y: cy - hh * 0.85)
            baseR = CGPoint(x: cx - hw * 0.4, y: cy + hh * 0.85)
        } else if tipDirection.x == -1 {
            tip = CGPoint(x: cx - hw, y: cy)
            baseL = CGPoint(x: cx + hw * 0.4, y: cy + hh * 0.85)
            baseR = CGPoint(x: cx + hw * 0.4, y: cy - hh * 0.85)
        } else if tipDirection.y == 1 {
            tip = CGPoint(x: cx, y: cy - hh)
            baseL = CGPoint(x: cx - hw * 0.85, y: cy + hh * 0.4)
            baseR = CGPoint(x: cx + hw * 0.85, y: cy + hh * 0.4)
        } else if tipDirection.y == -1 {
            tip = CGPoint(x: cx, y: cy + hh)
            baseL = CGPoint(x: cx + hw * 0.85, y: cy - hh * 0.4)
            baseR = CGPoint(x: cx - hw * 0.85, y: cy - hh * 0.4)
        } else {
            return Path(roundedRect: inset, cornerRadius: hw * 0.5)
        }

        path.move(to: tip)
        path.addLine(to: baseL)
        path.addQuadCurve(to: baseR, control: CGPoint(x: cx - CGFloat(tipDirection.x) * hw * 0.6, y: cy + CGFloat(tipDirection.y) * hh * 0.6))
        path.closeSubpath()
        return path
    }

    private static func mid(_ a: CGPoint, _ b: CGPoint, bulge: CGFloat) -> CGPoint {
        CGPoint(
            x: (a.x + b.x) * 0.5 + (b.y - a.y) * bulge,
            y: (a.y + b.y) * 0.5 - (b.x - a.x) * bulge
        )
    }

    // MARK: - Items

    static func drawItem(type: ItemType, in rect: CGRect, context: inout GraphicsContext) {
        switch type {
        case .shield: drawShield(in: rect, context: &context)
        case .bomb: drawBomb(in: rect, context: &context)
        case .sword: drawSword(in: rect, context: &context)
        case .boomerang: drawBoomerang(in: rect, context: &context)
        case .greenApple:
            drawApple(
                in: rect,
                fill: Color(red: 0.35, green: 0.78, blue: 0.28),
                context: &context,
                showShieldRing: false
            )
        }
    }

    private static func drawShield(in rect: CGRect, context: inout GraphicsContext) {
        let fill = Color(red: 0.35, green: 0.7, blue: 1.0)
        let rim = Color(red: 0.15, green: 0.4, blue: 0.75)
        let inset = rect.insetBy(dx: rect.width * 0.08, dy: rect.height * 0.08)

        var shield = Path()
        let top = CGPoint(x: inset.midX, y: inset.minY)
        let left = CGPoint(x: inset.minX, y: inset.minY + inset.height * 0.28)
        let bottom = CGPoint(x: inset.midX, y: inset.maxY)
        let right = CGPoint(x: inset.maxX, y: inset.minY + inset.height * 0.28)
        shield.move(to: top)
        shield.addQuadCurve(to: left, control: CGPoint(x: inset.minX, y: inset.minY))
        shield.addQuadCurve(to: bottom, control: CGPoint(x: inset.minX, y: inset.maxY - inset.height * 0.1))
        shield.addQuadCurve(to: right, control: CGPoint(x: inset.maxX, y: inset.maxY - inset.height * 0.1))
        shield.addQuadCurve(to: top, control: CGPoint(x: inset.maxX, y: inset.minY))
        shield.closeSubpath()

        context.fill(shield, with: .color(fill))
        context.stroke(shield, with: .color(rim), lineWidth: max(1.5, rect.width * 0.07))

        // Cross
        var cross = Path()
        let cx = inset.midX
        let cy = inset.midY
        let arm = inset.width * 0.22
        cross.move(to: CGPoint(x: cx - arm, y: cy))
        cross.addLine(to: CGPoint(x: cx + arm, y: cy))
        cross.move(to: CGPoint(x: cx, y: cy - arm))
        cross.addLine(to: CGPoint(x: cx, y: cy + arm))
        context.stroke(cross, with: .color(.white.opacity(0.9)), lineWidth: max(1.5, rect.width * 0.08))

        // Boss
        let boss = CGRect(x: cx - inset.width * 0.08, y: cy - inset.height * 0.08, width: inset.width * 0.16, height: inset.height * 0.16)
        context.fill(Path(ellipseIn: boss), with: .color(.white.opacity(0.85)))
    }

    private static func drawBomb(in rect: CGRect, context: inout GraphicsContext) {
        let body = Color(red: 0.18, green: 0.18, blue: 0.2)
        let fuse = Color(red: 0.55, green: 0.35, blue: 0.15)
        let spark = Color(red: 1.0, green: 0.75, blue: 0.2)

        let ball = CGRect(
            x: rect.minX + rect.width * 0.12,
            y: rect.minY + rect.height * 0.28,
            width: rect.width * 0.7,
            height: rect.height * 0.62
        )
        context.fill(Path(ellipseIn: ball), with: .color(body))
        context.stroke(Path(ellipseIn: ball), with: .color(.white.opacity(0.15)), lineWidth: 1)

        var fusePath = Path()
        fusePath.move(to: CGPoint(x: ball.midX + ball.width * 0.15, y: ball.minY + ball.height * 0.08))
        fusePath.addQuadCurve(
            to: CGPoint(x: rect.midX + rect.width * 0.22, y: rect.minY + rect.height * 0.12),
            control: CGPoint(x: rect.maxX - rect.width * 0.08, y: rect.minY + rect.height * 0.35)
        )
        context.stroke(fusePath, with: .color(fuse), lineWidth: max(1.5, rect.width * 0.07))

        let sparkRect = CGRect(
            x: rect.midX + rect.width * 0.16,
            y: rect.minY + rect.height * 0.04,
            width: rect.width * 0.18,
            height: rect.height * 0.18
        )
        context.fill(Path(ellipseIn: sparkRect), with: .color(spark))
    }

    private static func drawSword(in rect: CGRect, context: inout GraphicsContext) {
        let blade = Color(red: 0.85, green: 0.88, blue: 0.95)
        let guardColor = Color(red: 0.9, green: 0.75, blue: 0.25)
        let grip = Color(red: 0.45, green: 0.25, blue: 0.12)

        // Blade (diagonal top-left to bottom-right tip-up)
        var bladePath = Path()
        let tip = CGPoint(x: rect.midX + rect.width * 0.28, y: rect.minY + rect.height * 0.08)
        let baseL = CGPoint(x: rect.midX - rect.width * 0.08, y: rect.midY + rect.height * 0.08)
        let baseR = CGPoint(x: rect.midX + rect.width * 0.08, y: rect.midY + rect.height * 0.18)
        bladePath.move(to: tip)
        bladePath.addLine(to: baseL)
        bladePath.addLine(to: baseR)
        bladePath.closeSubpath()
        context.fill(bladePath, with: .color(blade))
        context.stroke(bladePath, with: .color(.white.opacity(0.5)), lineWidth: 1)

        // Guard
        var guardPath = Path()
        guardPath.addRoundedRect(
            in: CGRect(
                x: rect.midX - rect.width * 0.28,
                y: rect.midY + rect.height * 0.05,
                width: rect.width * 0.42,
                height: rect.height * 0.1
            ),
            cornerSize: CGSize(width: 2, height: 2)
        )
        context.fill(guardPath, with: .color(guardColor))

        // Grip
        var gripPath = Path()
        gripPath.addRoundedRect(
            in: CGRect(
                x: rect.midX - rect.width * 0.07,
                y: rect.midY + rect.height * 0.16,
                width: rect.width * 0.12,
                height: rect.height * 0.28
            ),
            cornerSize: CGSize(width: 2, height: 2)
        )
        context.fill(gripPath, with: .color(grip))

        // Pommel
        let pommel = CGRect(
            x: rect.midX - rect.width * 0.08,
            y: rect.maxY - rect.height * 0.18,
            width: rect.width * 0.16,
            height: rect.height * 0.12
        )
        context.fill(Path(ellipseIn: pommel), with: .color(guardColor))
    }

    private static func drawBoomerang(in rect: CGRect, context: inout GraphicsContext) {
        let fill = Color(red: 0.85, green: 0.45, blue: 0.2)
        let edge = Color(red: 0.55, green: 0.25, blue: 0.08)
        let inset = rect.insetBy(dx: rect.width * 0.1, dy: rect.height * 0.12)

        var outer = Path()
        outer.move(to: CGPoint(x: inset.minX + inset.width * 0.15, y: inset.maxY - inset.height * 0.15))
        outer.addQuadCurve(
            to: CGPoint(x: inset.midX, y: inset.minY + inset.height * 0.15),
            control: CGPoint(x: inset.minX, y: inset.minY + inset.height * 0.1)
        )
        outer.addQuadCurve(
            to: CGPoint(x: inset.maxX - inset.width * 0.15, y: inset.maxY - inset.height * 0.15),
            control: CGPoint(x: inset.maxX, y: inset.minY + inset.height * 0.1)
        )
        outer.addQuadCurve(
            to: CGPoint(x: inset.midX, y: inset.midY + inset.height * 0.05),
            control: CGPoint(x: inset.maxX - inset.width * 0.25, y: inset.midY + inset.height * 0.2)
        )
        outer.addQuadCurve(
            to: CGPoint(x: inset.minX + inset.width * 0.15, y: inset.maxY - inset.height * 0.15),
            control: CGPoint(x: inset.minX + inset.width * 0.25, y: inset.midY + inset.height * 0.2)
        )
        outer.closeSubpath()

        context.fill(outer, with: .color(fill))
        context.stroke(outer, with: .color(edge), lineWidth: max(1, rect.width * 0.05))
    }
}
