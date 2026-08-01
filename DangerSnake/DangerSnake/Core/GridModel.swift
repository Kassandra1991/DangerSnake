import Foundation

struct GridModel: Sendable {
    let width: Int
    let height: Int

    func inBounds(_ pos: GridPos) -> Bool {
        pos.x >= 0 && pos.y >= 0 && pos.x < width && pos.y < height
    }

    func randomEmptyCell(occupied: Set<GridPos>) -> GridPos? {
        var free: [GridPos] = []
        free.reserveCapacity(width * height)
        for x in 0..<width {
            for y in 0..<height {
                let p = GridPos(x: x, y: y)
                if !occupied.contains(p) {
                    free.append(p)
                }
            }
        }
        return free.randomElement()
    }

    func collectOccupied(
        snake: [GridPos],
        apple: GridPos,
        items: [GridPos],
        into occupied: inout Set<GridPos>
    ) {
        occupied.removeAll(keepingCapacity: true)
        for s in snake { occupied.insert(s) }
        occupied.insert(apple)
        for i in items { occupied.insert(i) }
    }
}
