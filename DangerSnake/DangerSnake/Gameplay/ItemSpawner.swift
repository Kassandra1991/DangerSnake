import Foundation

final class ItemSpawner {
    private let config: GameConfig
    private(set) var items: [FieldItem] = []
    private var cooldown: TimeInterval
    private var clock: TimeInterval = 0

    init(config: GameConfig) {
        self.config = config
        self.cooldown = config.itemSpawnInterval * 0.5
    }

    func reset() {
        items.removeAll(keepingCapacity: true)
        cooldown = config.itemSpawnInterval * 0.5
        clock = 0
    }

    var positions: [GridPos] {
        items.map(\.position)
    }

    var greenApples: [FieldItem] {
        items.filter { $0.type == .greenApple }
    }

    var swords: [FieldItem] {
        items.filter { $0.type == .sword }
    }

    func nearestGreenApple(from pos: GridPos) -> FieldItem? {
        greenApples.min { a, b in
            pos.manhattan(a.position) < pos.manhattan(b.position)
        }
    }

    func nearestSword(from pos: GridPos) -> FieldItem? {
        swords.min { a, b in
            pos.manhattan(a.position) < pos.manhattan(b.position)
        }
    }

    /// Advances spawn cooldown and removes expired swords. Returns `true` if a sword vanished by TTL.
    @discardableResult
    func tickRealtime(dt: TimeInterval, grid: GridModel, occupied: Set<GridPos>) -> Bool {
        clock += dt
        let swordVanished = removeExpired()

        cooldown -= dt
        guard cooldown <= 0 else { return swordVanished }
        guard items.count < config.maxItemsOnField else {
            cooldown = config.itemSpawnInterval
            return swordVanished
        }

        if let cell = grid.randomEmptyCell(occupied: occupied) {
            let type = Self.randomSpawnType(greenWeight: config.greenAppleSpawnWeight)
            let expiresAt: TimeInterval? = type == .sword
                ? clock + config.swordLifetimeDuration
                : nil
            items.append(FieldItem(position: cell, type: type, expiresAt: expiresAt))
        }
        cooldown = config.itemSpawnInterval
        return swordVanished
    }

    func tryPickup(at pos: GridPos) -> ItemType? {
        guard let idx = items.firstIndex(where: { $0.position == pos }) else { return nil }
        let type = items[idx].type
        items.remove(at: idx)
        return type
    }

    /// Picks up gear/weapons only; leaves green apples on the field.
    func tryPickupGear(at pos: GridPos) -> ItemType? {
        guard let idx = items.firstIndex(where: { $0.position == pos }) else { return nil }
        let type = items[idx].type
        guard type != .greenApple else { return nil }
        items.remove(at: idx)
        return type
    }

    private func removeExpired() -> Bool {
        let before = items.count
        items.removeAll { item in
            guard let expiresAt = item.expiresAt else { return false }
            return expiresAt <= clock
        }
        return items.count < before
    }

    private static func randomSpawnType(greenWeight: Double) -> ItemType {
        if Double.random(in: 0...1) < greenWeight {
            return .greenApple
        }
        let gear: [ItemType] = [.shield, .bomb, .sword, .boomerang]
        return gear.randomElement() ?? .shield
    }
}
