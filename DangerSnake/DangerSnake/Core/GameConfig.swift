import Foundation

struct GameConfig: Sendable {
    var width: Int = 16
    var height: Int = 12
    var tickInterval: TimeInterval = 0.18
    var startLength: Int = 4
    var itemSpawnInterval: TimeInterval = 4.5
    var maxItemsOnField: Int = 3
    var attackChargeTicks: Int = 12
    var appleSeekItemBias: Double = 0.65

    static let `default` = GameConfig()
}
