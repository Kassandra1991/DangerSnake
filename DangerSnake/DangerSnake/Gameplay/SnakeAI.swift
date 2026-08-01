import Foundation

enum SnakeAI {
    /// Pick a chase step toward the apple without walking into the body when possible.
    static func chooseDirection(snake: Snake, apple: GridPos, grid: GridModel) -> GridPos {
        let target = apple
        var best = snake.direction
        var bestScore = Int.min

        for dir in Directions.all {
            if dir == Directions.opposite(snake.direction) { continue }

            let next = snake.head + dir
            guard grid.inBounds(next) else { continue }

            // Prefer not stepping onto body (except vacating tail handled in tickMove).
            var score = -next.manhattan(target) * 10
            if snake.occupies(next), next != snake.body.last {
                score -= 1000
            }
            // Slight bias to keep momentum.
            if dir == snake.direction {
                score += 1
            }
            score += Int.random(in: 0...1)

            if score > bestScore {
                bestScore = score
                best = dir
            }
        }

        return best
    }
}
