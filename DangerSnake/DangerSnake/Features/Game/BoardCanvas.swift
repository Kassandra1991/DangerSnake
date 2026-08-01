import SwiftUI

struct BoardCanvas: View {
    let engine: GameEngine
    var onSwipe: ((GridPos) -> Void)?

    private let boardDark = Color(red: 0.07, green: 0.12, blue: 0.09)
    private let boardLite = Color(red: 0.09, green: 0.16, blue: 0.11)
    private let snakeColor = Color(red: 0.35, green: 0.85, blue: 0.45)
    private let snakeHead = Color(red: 0.55, green: 1.0, blue: 0.6)
    private let appleColor = Color(red: 0.95, green: 0.25, blue: 0.28)
    private let appleArmed = Color(red: 1.0, green: 0.55, blue: 0.15)
    private let appleShield = Color(red: 0.4, green: 0.75, blue: 1.0)

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
                        .insetBy(dx: cell * 0.22, dy: cell * 0.22)
                    context.fill(Path(roundedRect: rect, cornerRadius: 4), with: .color(color(for: item.type)))
                }

                for (i, part) in engine.snakeBody.enumerated() {
                    let inset = i == 0 ? cell * 0.08 : cell * 0.14
                    let rect = cellRect(x: part.x, y: part.y, cell: cell, originX: originX, originY: originY, rows: engine.grid.height)
                        .insetBy(dx: inset, dy: inset)
                    context.fill(Path(roundedRect: rect, cornerRadius: 4), with: .color(i == 0 ? snakeHead : snakeColor))
                }

                let appleRect = cellRect(
                    x: engine.applePosition.x,
                    y: engine.applePosition.y,
                    cell: cell,
                    originX: originX,
                    originY: originY,
                    rows: engine.grid.height
                ).insetBy(dx: cell * 0.18, dy: cell * 0.18)
                let aColor: Color = {
                    if engine.hasShield { return appleShield }
                    if engine.appleWeapon != nil { return appleArmed }
                    return appleColor
                }()
                context.fill(Path(ellipseIn: appleRect), with: .color(aColor))
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

    private func color(for type: ItemType) -> Color {
        switch type {
        case .shield: return Color(red: 0.35, green: 0.7, blue: 1.0)
        case .bomb: return Color(red: 0.2, green: 0.2, blue: 0.22)
        case .sword: return Color(red: 0.9, green: 0.85, blue: 0.35)
        case .boomerang: return Color(red: 0.85, green: 0.45, blue: 0.2)
        }
    }
}
