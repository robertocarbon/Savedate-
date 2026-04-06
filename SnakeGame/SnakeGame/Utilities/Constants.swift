import SwiftUI

enum Constants {
    static let gridSize: Int = 20
    static let initialTickInterval: TimeInterval = 0.15
    static let minimumTickInterval: TimeInterval = 0.06
    static let speedIncrement: Double = 0.003

    static let snakeHeadColor = Color.green
    static let snakeBodyColor = Color(red: 0.18, green: 0.70, blue: 0.29)
    static let foodColor = Color.red
    static let backgroundColor = Color(red: 0.05, green: 0.05, blue: 0.10)
    static let gridLineColor = Color.white.opacity(0.05)
    static let cornerRadius: CGFloat = 3
}
