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

    private var tickTimer: TimeInterval = 0
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

    func startMatch() {
        stopLoop()
        grid = GridModel(width: config.width, height: config.height)
        items = ItemSpawner(config: config)

        let snakeStart = GridPos(x: config.width / 4, y: config.height / 2)
        snake.reset(start: snakeStart, length: config.startLength, initialDir: Directions.right)
        apple.reset(start: GridPos(x: config.width * 3 / 4, y: config.height / 2))
        items.reset()

        tickTimer = 0
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

        rebuildOccupied()
        items.tickRealtime(dt: dt, grid: grid, occupied: occupied)

        tickTimer += dt
        while tickTimer >= config.tickInterval {
            tickTimer -= config.tickInterval
            stepTick()
            if !isRunning { break }
        }

        renderTick &+= 1
    }

    private func stepTick() {
        rebuildOccupied()

        // 1) Player apple moves.
        let appleStep = apple.tickMove(grid: grid)

        // 2) Apple picks up items.
        if let picked = items.tryPickup(at: apple.position) {
            if picked == .shield {
                apple.pickup(picked)
                status = "Shield online!"
            } else {
                apple.pickup(picked)
                status = "Armed: \(picked.displayName)!"
            }
        }

        // 3) Armed apple combat (boomerang along last step, or contact).
        if let held = apple.heldItem {
            if held == .boomerang, appleStep.x != 0 || appleStep.y != 0 {
                if let boom = combat.tryBoomerangHit(
                    applePos: apple.position,
                    direction: appleStep,
                    snake: snake,
                    grid: grid
                ) {
                    apple.addScore(10)
                    status = Self.describePlayerHit(boom)
                    apple.consumeHeldItem()
                    if !snake.isAlive {
                        endVictory("Boomerang finish!")
                        return
                    }
                }
            }

            if snake.occupies(apple.position) {
                resolvePlayerAttack()
                if !snake.isAlive {
                    endVictory("You took down the snake!")
                    return
                }
            }
        }

        // 4) Snake AI hunts the apple.
        let chase = SnakeAI.chooseDirection(snake: snake, apple: apple.position, grid: grid)
        snake.setDirection(chase)
        if !snake.tickMove(grid: grid) {
            endVictory("Snake crashed!")
            return
        }

        // 5) Snake bite / mutual contact.
        if snake.head == apple.position {
            handleSnakeBite()
        }
    }

    private func resolvePlayerAttack() {
        guard let weapon = apple.heldItem else { return }
        let outcome = combat.applyAppleAttack(snake: snake, weapon: weapon)
        apple.addScore(10)
        status = Self.describePlayerHit(outcome)
        apple.consumeHeldItem()
    }

    private func handleSnakeBite() {
        if apple.hasShield {
            apple.consumeShield()
            status = "Shield blocked the bite!"
            // Nudge apple away if possible.
            return
        }

        if let weapon = apple.heldItem {
            // Last-second strike when colliding.
            let outcome = combat.applyAppleAttack(snake: snake, weapon: weapon)
            apple.addScore(10)
            apple.consumeHeldItem()
            status = Self.describePlayerHit(outcome)
            if !snake.isAlive {
                endVictory("Counter-attack!")
            }
            return
        }

        endGame("The snake ate you!")
    }

    private static func describePlayerHit(_ outcome: AttackOutcome) -> String {
        switch outcome {
        case .cutOne: return "Hit! Snake lost a segment."
        case .cutHalf: return "Bomb! Snake cut in half."
        case .kill: return "Sword finish!"
        case .blockedByShield, .none: return "Strike landed."
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
