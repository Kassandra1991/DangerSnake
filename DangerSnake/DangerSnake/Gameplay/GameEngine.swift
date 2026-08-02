import Foundation
import Observation
import QuartzCore

@Observable
final class GameEngine {
    private(set) var config: GameConfig
    private(set) var grid: GridModel
    private(set) var snake = Snake()
    private(set) var apple = PlayerApple()
    private(set) var items: ItemSpawner
    private let combat = CombatResolver()

    private(set) var status = ""
    private(set) var isRunning = false
    private(set) var isGameOver = false
    private(set) var isVictory = false
    private(set) var gameOverReason = ""
    private(set) var renderTick: UInt64 = 0
    private(set) var awaitingFirstInput = true
    private(set) var snakeStunRemaining: TimeInterval = 0
    private(set) var boomerangFlight: BoomerangFlight?

    private var tickTimer: TimeInterval = 0
    private var snakeTickTimer: TimeInterval = 0
    private var matchElapsed: TimeInterval = 0
    private var occupied = Set<GridPos>()
    private var displayLink: CADisplayLinkProxy?

    init(config: GameConfig = .default) {
        self.config = config
        self.grid = GridModel(width: config.width, height: config.height)
        self.items = ItemSpawner(config: config)
    }

    var score: Int { apple.score }
    var hasShield: Bool { apple.hasShield }
    var appleWeapon: ItemType? { apple.heldItem }
    var fieldItems: [FieldItem] { items.items }
    var snakeBody: [GridPos] { snake.body }
    var snakeDirection: GridPos { snake.direction }
    var applePosition: GridPos { apple.position }
    var isSnakeStunned: Bool { snakeStunRemaining > 0 }

    /// Interpolated board position of a flying boomerang, if any.
    var boomerangFlightDisplay: (x: Double, y: Double)? {
        guard let flight = boomerangFlight else { return nil }
        let t = flight.progress
        let x = Double(flight.from.x) + (Double(flight.to.x) - Double(flight.from.x)) * t
        let y = Double(flight.from.y) + (Double(flight.to.y) - Double(flight.from.y)) * t
        return (x, y)
    }

    func startMatch() {
        stopLoop()
        grid = GridModel(width: config.width, height: config.height)
        items = ItemSpawner(config: config)

        let snakeStart = GridPos(x: config.width / 4, y: config.height / 2)
        snake.reset(start: snakeStart, length: config.startLength, initialDir: Directions.right)
        apple.reset(start: GridPos(x: config.width * 3 / 4, y: config.height / 2))
        items.reset()

        tickTimer = 0
        snakeTickTimer = 0
        matchElapsed = 0
        snakeStunRemaining = 0
        boomerangFlight = nil
        isRunning = true
        isGameOver = false
        isVictory = false
        gameOverReason = ""
        awaitingFirstInput = true
        status = "Swipe or tap arrows to start.\nYou are the apple — the snake hunts you!"
        renderTick &+= 1
        startLoop()
    }

    func restart() {
        startMatch()
    }

    func queueDirection(_ dir: GridPos) {
        guard isRunning else { return }
        if awaitingFirstInput {
            awaitingFirstInput = false
            apple.setDirection(dir)
            status = "Flee, grab weapons, strike the snake!"
            renderTick &+= 1
            return
        }
        apple.setDirection(dir)
    }

    func stop() {
        stopLoop()
        isRunning = false
    }

    private func startLoop() {
        let proxy = CADisplayLinkProxy { [weak self] dt in
            self?.frame(dt: dt)
        }
        displayLink = proxy
        proxy.start()
    }

    private func stopLoop() {
        displayLink?.stop()
        displayLink = nil
    }

    private func frame(dt: TimeInterval) {
        guard isRunning else { return }
        if awaitingFirstInput { return }

        matchElapsed += dt
        if snakeStunRemaining > 0 {
            snakeStunRemaining = max(0, snakeStunRemaining - dt)
            if snakeStunRemaining == 0 {
                status = "Snake is moving again!"
            }
        }

        rebuildOccupied()
        if items.tickRealtime(dt: dt, grid: grid, occupied: occupied) {
            status = "Sword vanished!"
        }

        updateBoomerangFlight(dt: dt)
        if isRunning {
            tryStartBoomerangFlight()
        }

        tickTimer += dt
        while isRunning, tickTimer >= config.tickInterval {
            tickTimer -= config.tickInterval
            stepAppleTick()
            if !isRunning { break }
        }

        let snakeInterval = config.snakeInterval(afterElapsed: matchElapsed)
        snakeTickTimer += dt
        while isRunning, snakeTickTimer >= snakeInterval {
            snakeTickTimer -= snakeInterval
            stepSnakeTick()
            if !isRunning { break }
            tryStartBoomerangFlight()
        }

        renderTick &+= 1
    }

    private func stepAppleTick() {
        rebuildOccupied()

        let blocked = Set(items.greenApples.map(\.position))
        _ = apple.tickMove(grid: grid, blocked: blocked)

        if let picked = items.tryPickupGear(at: apple.position) {
            switch picked {
            case .greenApple:
                break
            case .shield:
                apple.pickup(picked)
                status = "Shield online!"
            case .bomb, .sword, .boomerang:
                apple.pickup(picked)
                status = "Armed: \(picked.displayName)!"
            }
        }

        tryStartBoomerangFlight()

        if let held = apple.heldItem, snake.occupies(apple.position) {
            resolvePlayerAttack()
            if !isRunning { return }
        }

        if snake.head == apple.position, snakeStunRemaining <= 0 {
            handleSnakeBite()
        }
    }

    private func stepSnakeTick() {
        rebuildOccupied()

        if snakeStunRemaining > 0 {
            return
        }

        let target: GridPos
        if let sword = items.nearestSword(from: snake.head) {
            target = sword.position
        } else if let food = items.nearestGreenApple(from: snake.head) {
            target = food.position
        } else {
            target = apple.position
        }

        let chase = SnakeAI.chooseDirection(snake: snake, target: target, grid: grid)
        snake.setDirection(chase)
        if !snake.tickMove(grid: grid) {
            endVictory("Snake crashed!")
            return
        }

        if let landed = items.tryPickup(at: snake.head) {
            switch landed {
            case .greenApple:
                snake.queueGrow()
                status = "Snake grew!"
            case .sword:
                status = "Snake secured the sword!"
            default:
                break
            }
        }

        if snake.head == apple.position {
            handleSnakeBite()
        }
    }

    private func resolvePlayerAttack() {
        guard let weapon = apple.heldItem else { return }
        let outcome = combat.applyAppleAttack(snake: snake, weapon: weapon)
        applyCombatOutcome(outcome, consumeWeapon: true)
    }

    private func applyCombatOutcome(_ outcome: AttackOutcome, consumeWeapon: Bool) {
        if consumeWeapon {
            apple.consumeHeldItem()
        }
        apple.addScore(10)
        status = Self.describePlayerHit(outcome)

        switch outcome {
        case .stun:
            snakeStunRemaining = config.bombStunDuration
            status = "Bomb! Snake stunned!"
        case .kill:
            endVictory("Sword finish!")
        case .cutOne, .cutHalf:
            if !snake.isAlive {
                endVictory("You took down the snake!")
            }
        case .blockedByShield, .none:
            break
        }
    }

    private func handleSnakeBite() {
        if apple.hasShield {
            apple.consumeShield()
            status = "Shield blocked the bite!"
            return
        }

        if let weapon = apple.heldItem {
            let outcome = combat.applyAppleAttack(snake: snake, weapon: weapon)
            applyCombatOutcome(outcome, consumeWeapon: true)
            if outcome == .stun {
                status = "Counter-bomb! Snake stunned!"
            } else if !snake.isAlive && isRunning {
                endVictory("Counter-attack!")
            }
            return
        }

        endGame("The snake ate you!")
    }

    private static func describePlayerHit(_ outcome: AttackOutcome) -> String {
        switch outcome {
        case .cutOne: return "Hit! Snake lost a segment."
        case .cutHalf: return "Boomerang slash!"
        case .stun: return "Bomb! Snake stunned!"
        case .kill: return "Sword finish!"
        case .blockedByShield, .none: return "Strike landed."
        }
    }

    private func nearestSnakeSegment(from pos: GridPos) -> GridPos? {
        snake.body.min { a, b in
            pos.manhattan(a) < pos.manhattan(b)
        }
    }

    private func tryStartBoomerangFlight() {
        guard isRunning, boomerangFlight == nil else { return }
        guard apple.heldItem == .boomerang else { return }
        guard let target = nearestSnakeSegment(from: apple.position) else { return }
        guard apple.position.manhattan(target) <= config.boomerangTriggerRange else { return }

        apple.consumeHeldItem()
        boomerangFlight = BoomerangFlight(
            from: apple.position,
            to: target,
            elapsed: 0,
            duration: config.boomerangFlightDuration
        )
        status = "Boomerang away!"
    }

    private func updateBoomerangFlight(dt: TimeInterval) {
        guard var flight = boomerangFlight else { return }
        flight.elapsed += dt
        if flight.elapsed >= flight.duration {
            boomerangFlight = nil
            let outcome = combat.applyAppleAttack(snake: snake, weapon: .boomerang)
            applyCombatOutcome(outcome, consumeWeapon: false)
        } else {
            boomerangFlight = flight
        }
    }

    private func rebuildOccupied() {
        grid.collectOccupied(
            snake: snake.body,
            apple: apple.position,
            items: items.positions,
            into: &occupied
        )
    }

    private func endGame(_ reason: String) {
        isRunning = false
        isGameOver = true
        isVictory = false
        gameOverReason = reason
        status = reason
        renderTick &+= 1
        stopLoop()
    }

    private func endVictory(_ reason: String) {
        isRunning = false
        isGameOver = true
        isVictory = true
        gameOverReason = reason
        status = reason
        renderTick &+= 1
        stopLoop()
    }
}

private final class CADisplayLinkProxy: NSObject {
    private var link: CADisplayLink?
    private let handler: (TimeInterval) -> Void
    private var lastTimestamp: CFTimeInterval = 0

    init(handler: @escaping (TimeInterval) -> Void) {
        self.handler = handler
        super.init()
    }

    func start() {
        let link = CADisplayLink(target: self, selector: #selector(tick))
        link.add(to: .main, forMode: .common)
        self.link = link
        lastTimestamp = 0
    }

    func stop() {
        link?.invalidate()
        link = nil
    }

    @objc private func tick(_ link: CADisplayLink) {
        if lastTimestamp == 0 {
            lastTimestamp = link.timestamp
            return
        }
        let dt = link.timestamp - lastTimestamp
        lastTimestamp = link.timestamp
        handler(dt)
    }
}

struct BoomerangFlight: Sendable {
    var from: GridPos
    var to: GridPos
    var elapsed: TimeInterval
    var duration: TimeInterval

    var progress: Double {
        guard duration > 0 else { return 1 }
        return min(1, elapsed / duration)
    }
}
