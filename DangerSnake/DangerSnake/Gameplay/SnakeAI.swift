import Foundation

enum SnakeAI {
    /// Pick a chase step toward `target` without walking into the body when possible.
    static func chooseDirection(snake: Snake, target: GridPos, grid: GridModel) -> GridPos {
        var best = snake.direction
        var bestScore = Int.min

        for dir in Directions.all {
            if dir == Directions.opposite(snake.direction) { continue }

            let next = snake.head + dir
            guard grid.inBounds(next) else { continue }

            var score = -next.manhattan(target) * 10
            if snake.occupies(next), next != snake.body.last {
                score -= 1000
            }
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
