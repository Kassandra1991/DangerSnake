import Foundation

enum ItemType: Int, CaseIterable, Sendable {
    case shield = 0
    case bomb = 1
    case sword = 2
    case boomerang = 3
    case greenApple = 4

    var displayName: String {
        switch self {
        case .shield: return "Shield"
        case .bomb: return "Bomb"
        case .sword: return "Sword"
        case .boomerang: return "Boomerang"
        case .greenApple: return "Green Apple"
        }
    }

    var isWeaponOrGear: Bool {
        switch self {
        case .shield, .bomb, .sword, .boomerang: return true
        case .greenApple: return false
        }
    }
}

enum AttackOutcome: Sendable {
    case none
    case blockedByShield
    case cutOne
    case cutHalf
    case stun
    case kill
}

enum ItemEffect {
    static func resolveAppleAttack(_ item: ItemType) -> AttackOutcome {
        switch item {
        case .bomb: return .stun
        case .sword: return .kill
        case .boomerang: return .cutHalf
        case .shield: return .cutOne
        case .greenApple: return .none
        }
    }
}

struct FieldItem: Identifiable, Sendable {
    let id = UUID()
    var position: GridPos
    var type: ItemType
    /// Absolute spawner clock time; sword despawns when reached.
    var expiresAt: TimeInterval?

    init(position: GridPos, type: ItemType, expiresAt: TimeInterval? = nil) {
        self.position = position
        self.type = type
        self.expiresAt = expiresAt
    }
}
