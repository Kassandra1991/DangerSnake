import Foundation

final class PlayerApple {
    private(set) var position = GridPos(x: 0, y: 0)
    private var pendingDir = GridPos(x: 0, y: 0)
    private(set) var lastStep = GridPos(x: 0, y: 0)
    private(set) var heldItem: ItemType?
    private(set) var hasShield = false
    private(set) var score = 0

    func reset(start: GridPos) {
        position = start
        pendingDir = GridPos(x: 0, y: 0)
        lastStep = GridPos(x: 0, y: 0)
        heldItem = nil
        hasShield = false
        score = 0
    }

    func setDirection(_ dir: GridPos) {
        guard dir.x != 0 || dir.y != 0 else { return }
        pendingDir = dir
    }

    func grantShield() {
        hasShield = true
    }

    func consumeShield() {
        hasShield = false
    }

    func addScore(_ amount: Int) {
        score += amount
    }

    /// Move one cell; stops at edges and blocked cells (no wall death).
    @discardableResult
    func tickMove(grid: GridModel, blocked: Set<GridPos> = []) -> GridPos {
        lastStep = GridPos(x: 0, y: 0)
        guard pendingDir.x != 0 || pendingDir.y != 0 else { return lastStep }

        let next = position + pendingDir
        guard grid.inBounds(next) else { return lastStep }
        guard !blocked.contains(next) else { return lastStep }

        position = next
        lastStep = pendingDir
        return lastStep
    }

    func pickup(_ type: ItemType) {
        switch type {
        case .shield:
            grantShield()
            addScore(10)
        case .greenApple:
            addScore(5)
        case .bomb, .sword, .boomerang:
            heldItem = type
            addScore(10)
        }
    }

    func consumeHeldItem() {
        heldItem = nil
    }
}
