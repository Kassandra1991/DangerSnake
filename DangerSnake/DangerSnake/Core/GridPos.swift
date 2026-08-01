import Foundation

struct GridPos: Hashable, Equatable, Sendable {
    var x: Int
    var y: Int

    static func + (lhs: GridPos, rhs: GridPos) -> GridPos {
        GridPos(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
    }

    static func - (lhs: GridPos, rhs: GridPos) -> GridPos {
        GridPos(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
    }

    func manhattan(_ other: GridPos) -> Int {
        abs(x - other.x) + abs(y - other.y)
    }
}

enum Directions {
    static let up = GridPos(x: 0, y: 1)
    static let down = GridPos(x: 0, y: -1)
    static let left = GridPos(x: -1, y: 0)
    static let right = GridPos(x: 1, y: 0)
    static let all = [up, down, left, right]

    static func opposite(_ dir: GridPos) -> GridPos {
        if dir == up { return down }
        if dir == down { return up }
        if dir == left { return right }
        if dir == right { return left }
        return dir
    }
}
