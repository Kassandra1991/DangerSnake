import Foundation

struct CombatResolver {
    /// Apple weapon hits the hunting snake (no snake shield — shield is on the apple).
    func applyAppleAttack(snake: Snake, weapon: ItemType) -> AttackOutcome {
        let outcome = ItemEffect.resolveAppleAttack(weapon)
        switch outcome {
        case .cutOne:
            snake.trimCells(1)
        case .cutHalf:
            snake.trimCells(max(1, snake.length / 2))
        case .kill:
            snake.kill()
        case .blockedByShield, .none:
            break
        }
        return outcome
    }

    func tryBoomerangHit(
        applePos: GridPos,
        direction: GridPos,
        snake: Snake,
        grid: GridModel
    ) -> AttackOutcome? {
        var cursor = applePos + direction
        while grid.inBounds(cursor) {
            if snake.occupies(cursor) {
                return applyAppleAttack(snake: snake, weapon: .boomerang)
            }
            cursor = cursor + direction
        }
        return nil
    }
}
