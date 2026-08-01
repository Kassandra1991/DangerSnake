import Foundation

final class ItemSpawner {
    private let config: GameConfig
    private(set) var items: [FieldItem] = []
    private var cooldown: TimeInterval

    init(config: GameConfig) {
        self.config = config
        self.cooldown = config.itemSpawnInterval * 0.5
    }

    func reset() {
        items.removeAll(keepingCapacity: true)
        cooldown = config.itemSpawnInterval * 0.5
    }

    var positions: [GridPos] {
        items.map(\.position)
    }

    func tickRealtime(dt: TimeInterval, grid: GridModel, occupied: Set<GridPos>) {
        cooldown -= dt
        guard cooldown <= 0 else { return }
        guard items.count < config.maxItemsOnField else { return }

        if let cell = grid.randomEmptyCell(occupied: occupied),
           let type = ItemType.allCases.randomElement() {
            items.append(FieldItem(position: cell, type: type))
        }
        cooldown = config.itemSpawnInterval
    }

    func tryPickup(at pos: GridPos) -> ItemType? {
        guard let idx = items.firstIndex(where: { $0.position == pos }) else { return nil }
        let type = items[idx].type
        items.remove(at: idx)
        return type
    }
}
