import SwiftUI

struct BoardCanvas: View {
    let engine: GameEngine
    var onSwipe: ((GridPos) -> Void)?

    private let boardDark = Color(red: 0.07, green: 0.12, blue: 0.09)
    private let boardLite = Color(red: 0.09, green: 0.16, blue: 0.11)
    private let snakeBodyFill = Color(red: 0.28, green: 0.72, blue: 0.38)
    private let snakeHeadFill = Color(red: 0.42, green: 0.88, blue: 0.48)
    private let snakeTailFill = Color(red: 0.2, green: 0.55, blue: 0.28)
    private let appleColor = Color(red: 0.9, green: 0.18, blue: 0.22)
    private let appleArmed = Color(red: 0.95, green: 0.45, blue: 0.12)
    private let appleShieldBody = Color(red: 0.75, green: 0.2, blue: 0.28)

    var body: some View {
        let _ = engine.renderTick

        GeometryReader { geo in
            let cols = CGFloat(engine.grid.width)
            let rows = CGFloat(engine.grid.height)
            let cell = min(geo.size.width / cols, geo.size.height / rows)
            let boardW = cell * cols
            let boardH = cell * rows
            let originX = (geo.size.width - boardW) / 2
            let originY = (geo.size.height - boardH) / 2

            Canvas { context, _ in
                for x in 0..<engine.grid.width {
                    for y in 0..<engine.grid.height {
                        let color = (x + y).isMultiple(of: 2) ? boardDark : boardLite
                        let rect = cellRect(x: x, y: y, cell: cell, originX: originX, originY: originY, rows: engine.grid.height)
                        context.fill(Path(roundedRect: rect.insetBy(dx: 1, dy: 1), cornerRadius: 2), with: .color(color))
                    }
                }

                for item in engine.fieldItems {
                    let rect = cellRect(x: item.position.x, y: item.position.y, cell: cell, originX: originX, originY: originY, rows: engine.grid.height)
                        .insetBy(dx: cell * 0.14, dy: cell * 0.14)
                    EntityShapes.drawItem(type: item.type, in: rect, context: &context)
                }

                let body = engine.snakeBody
                for (i, part) in body.enumerated() {
                    let isHead = i == 0
                    let isTail = i == body.count - 1 && body.count > 1
                    let inset: CGFloat = {
                        if isHead { return cell * 0.06 }
                        if isTail { return cell * 0.16 }
                        let t = CGFloat(i) / CGFloat(max(1, body.count - 1))
                        return cell * (0.12 + t * 0.06)
                    }()
                    let rect = cellRect(x: part.x, y: part.y, cell: cell, originX: originX, originY: originY, rows: engine.grid.height)
                        .insetBy(dx: inset, dy: inset)

                    if isHead {
                        EntityShapes.drawSnakeHead(
                            in: rect,
                            direction: engine.snakeDirection,
                            fill: snakeHeadFill,
                            context: &context
                        )
                    } else if isTail {
                        let tipDir: GridPos = {
                            if body.count >= 2 {
                                let before = body[body.count - 2]
                                return GridPos(x: part.x - before.x, y: part.y - before.y)
                            }
                            return GridPos(x: -engine.snakeDirection.x, y: -engine.snakeDirection.y)
                        }()
                        EntityShapes.drawSnakeTail(
                            in: rect,
                            towardTailFrom: tipDir,
                            fill: snakeTailFill,
                            context: &context
                        )
                    } else {
                        let t = CGFloat(i) / CGFloat(max(1, body.count - 1))
                        let fill = snakeBodyFill.opacity(1.0 - t * 0.25)
                        EntityShapes.drawSnakeBody(in: rect, fill: fill, context: &context)
                    }
                }

                let appleRect = cellRect(
                    x: engine.applePosition.x,
                    y: engine.applePosition.y,
                    cell: cell,
                    originX: originX,
                    originY: originY,
                    rows: engine.grid.height
                ).insetBy(dx: cell * 0.12, dy: cell * 0.12)
                let aColor: Color = {
                    if engine.appleWeapon != nil { return appleArmed }
                    if engine.hasShield { return appleShieldBody }
                    return appleColor
                }()
                EntityShapes.drawApple(
                    in: appleRect,
                    fill: aColor,
                    context: &context,
                    showShieldRing: engine.hasShield
                )
            }
            .frame(width: geo.size.width, height: geo.size.height)
            .contentShape(Rectangle())
            .onSwipeDirection { onSwipe?($0) }
        }
    }

    private func cellRect(x: Int, y: Int, cell: CGFloat, originX: CGFloat, originY: CGFloat, rows: Int) -> CGRect {
        let flippedY = CGFloat(rows - 1 - y)
        return CGRect(
            x: originX + CGFloat(x) * cell,
            y: originY + flippedY * cell,
            width: cell,
            height: cell
        )
    }
}
