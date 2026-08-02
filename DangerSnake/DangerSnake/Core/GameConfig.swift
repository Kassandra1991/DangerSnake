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
