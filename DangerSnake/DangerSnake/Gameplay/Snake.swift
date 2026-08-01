import Foundation

final class Snake {
    private(set) var body: [GridPos] = []
    private var pendingDir = Directions.right
    private(set) var direction = Directions.right
    private var growNext = false
    private var alive = true

    private(set) var hasShield = false
    private(set) var score = 0

    var head: GridPos { body[0] }
    var length: Int { body.count }
    var isAlive: Bool { alive && !body.isEmpty }

    func reset(start: GridPos, length: Int, initialDir: GridPos) {
        body.removeAll(keepingCapacity: true)
        direction = initialDir
        pendingDir = initialDir
        growNext = false
        alive = true
        hasShield = false
        score = 0

        for i in 0..<length {
            body.append(GridPos(x: start.x - initialDir.x * i, y: start.y - initialDir.y * i))
        }
    }

    func setDirection(_ dir: GridPos) {
        guard dir.x != 0 || dir.y != 0 else { return }
        guard dir != Directions.opposite(direction) else { return }
        pendingDir = dir
    }

    func grantShield() { hasShield = true }
    func consumeShield() { hasShield = false }

    func queueGrow() {
        growNext = true
        score += 10
    }

    func occupies(_ pos: GridPos) -> Bool {
        body.contains(pos)
    }

    func trimCells(_ count: Int) {
        guard count > 0 else { return }
        let remove = min(count, max(0, body.count - 1))
        if remove <= 0 {
            kill()
            return
        }
        body.removeLast(remove)
        if body.isEmpty { kill() }
    }

    func kill() {
        alive = false
    }

    /// Advances one cell. Returns false if the snake dies from wall/self.
    @discardableResult
    func tickMove(grid: GridModel) -> Bool {
        guard isAlive else { return false }

        direction = pendingDir
        let next = head + direction

        guard grid.inBounds(next) else {
            kill()
            return false
        }

        let tail = body[body.count - 1]
        if let idx = body.firstIndex(of: next) {
            let isVacatingTail = !growNext && next == tail && idx == body.count - 1
            if !isVacatingTail {
                kill()
                return false
            }
        }

        body.insert(next, at: 0)
        if growNext {
            growNext = false
        } else {
            body.removeLast()
        }
        return true
    }
}
