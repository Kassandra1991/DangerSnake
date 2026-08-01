import Foundation

enum ItemType: Int, CaseIterable, Sendable {
    case shield = 0
    case bomb = 1
    case sword = 2
    case boomerang = 3

    var displayName: String {
        switch self {
        case .shield: return "Shield"
        case .bomb: return "Bomb"
        case .sword: return "Sword"
        case .boomerang: return "Boomerang"
        }
    }
}

enum AttackOutcome: Sendable {
    case none
    case blockedByShield
    case cutOne
    case cutHalf
    case kill
}

enum ItemEffect {
    static func resolveAppleAttack(_ item: ItemType) -> AttackOutcome {
        switch item {
        case .bomb: return .cutHalf
        case .sword: return .kill
        case .boomerang, .shield: return .cutOne
        }
    }
}

struct FieldItem: Identifiable, Sendable {
    let id = UUID()
    var position: GridPos
    var type: ItemType
}
