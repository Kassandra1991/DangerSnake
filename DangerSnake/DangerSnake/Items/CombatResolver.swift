import Foundation

struct CombatResolver {
    /// Apple weapon hits the hunting snake. Stun is signaled via outcome; engine applies duration.
    func applyAppleAttack(snake: Snake, weapon: ItemType) -> AttackOutcome {
        let outcome = ItemEffect.resolveAppleAttack(weapon)
        switch outcome {
        case .cutOne:
            snake.trimCells(1)
        case .cutHalf:
            snake.trimCells(max(1, snake.length / 2))
        case .kill:
            snake.kill()
        case .stun, .blockedByShield, .none:
            break
        }
        return outcome
    }
}
