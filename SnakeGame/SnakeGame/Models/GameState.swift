import SwiftUI
import Combine

enum GamePhase {
    case notStarted
    case playing
    case gameOver
}

@MainActor
class GameState: ObservableObject {
    @Published var snake: [GridPosition] = []
    @Published var food: GridPosition = GridPosition(x: 0, y: 0)
    @Published var direction: Direction = .right
    @Published var score: Int = 0
    @Published var highScore: Int = UserDefaults.standard.integer(forKey: "snakeHighScore")
    @Published var gamePhase: GamePhase = .notStarted

    private var nextDirection: Direction = .right
    private var bodySet: Set<GridPosition> = []
    private var gameTimer: Timer?

    let gridSize = Constants.gridSize

    var tickInterval: TimeInterval {
        max(Constants.minimumTickInterval,
            Constants.initialTickInterval - Double(score) * Constants.speedIncrement)
    }

    func startGame() {
        let midX = gridSize / 2
        let midY = gridSize / 2
        snake = [
            GridPosition(x: midX, y: midY),
            GridPosition(x: midX - 1, y: midY),
            GridPosition(x: midX - 2, y: midY)
        ]
        bodySet = Set(snake)
        direction = .right
        nextDirection = .right
        score = 0
        gamePhase = .playing
        spawnFood()
        startTimer()
    }

    func changeDirection(_ newDirection: Direction) {
        if newDirection != direction.opposite {
            nextDirection = newDirection
            HapticManager.directionChanged()
        }
    }

    func pauseGame() {
        gameTimer?.invalidate()
        gameTimer = nil
    }

    func resumeGame() {
        guard gamePhase == .playing else { return }
        startTimer()
    }

    private func startTimer() {
        gameTimer?.invalidate()
        gameTimer = Timer.scheduledTimer(withTimeInterval: tickInterval, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.tick()
            }
        }
    }

    private func tick() {
        guard gamePhase == .playing else { return }

        if nextDirection != direction.opposite {
            direction = nextDirection
        }

        let newHead = snake[0].moved(in: direction)

        // Wall collision
        if newHead.x < 0 || newHead.x >= gridSize || newHead.y < 0 || newHead.y >= gridSize {
            endGame()
            return
        }

        // Self collision
        if bodySet.contains(newHead) {
            endGame()
            return
        }

        snake.insert(newHead, at: 0)
        bodySet.insert(newHead)

        if newHead == food {
            score += 1
            HapticManager.foodEaten()
            spawnFood()
            // Restart timer with new speed
            startTimer()
        } else {
            let tail = snake.removeLast()
            bodySet.remove(tail)
        }
    }

    private func endGame() {
        gamePhase = .gameOver
        gameTimer?.invalidate()
        gameTimer = nil
        HapticManager.gameOver()
        if score > highScore {
            highScore = score
            UserDefaults.standard.set(highScore, forKey: "snakeHighScore")
        }
    }

    private func spawnFood() {
        let allPositions = Set((0..<gridSize).flatMap { x in
            (0..<gridSize).map { y in GridPosition(x: x, y: y) }
        })
        let available = allPositions.subtracting(bodySet)
        if let pos = available.randomElement() {
            food = pos
        }
    }
}
