import Foundation

struct GameConfig: Sendable {
    var width: Int = 16
    var height: Int = 12
    /// Player apple / combat tick.
    var tickInterval: TimeInterval = 0.18
    var startLength: Int = 4
    var itemSpawnInterval: TimeInterval = 4.5
    var maxItemsOnField: Int = 3
    var attackChargeTicks: Int = 12
    var appleSeekItemBias: Double = 0.65

    // Snake hunt pace (slower early, ramps to tickInterval).
    var snakeSlowInterval: TimeInterval = 0.36
    var snakeMidInterval: TimeInterval = 0.26
    var snakeFastInterval: TimeInterval = 0.18
    var snakeMidPhaseStart: TimeInterval = 10
    var snakeFastPhaseStart: TimeInterval = 25
    var bombStunDuration: TimeInterval = 4
    /// How long a sword stays on the field before vanishing.
    var swordLifetimeDuration: TimeInterval = 4
    /// Chance a spawn is snake food instead of gear.
    var greenAppleSpawnWeight: Double = 0.35
    /// Auto-fire boomerang when snake is this close (manhattan).
    var boomerangTriggerRange: Int = 3
    var boomerangFlightDuration: TimeInterval = 0.28

    func snakeInterval(afterElapsed elapsed: TimeInterval) -> TimeInterval {
        if elapsed < snakeMidPhaseStart {
            return snakeSlowInterval
        }
        if elapsed < snakeFastPhaseStart {
            return snakeMidInterval
        }
        return snakeFastInterval
    }

    static let `default` = GameConfig()
}
