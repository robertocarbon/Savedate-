import SwiftUI

struct GameBoardView: View {
    @ObservedObject var game: GameState
    let boardSize: CGFloat

    var body: some View {
        TimelineView(.animation(minimumInterval: 0.5)) { timeline in
            Canvas { context, size in
                let cellSize = size.width / CGFloat(Constants.gridSize)

                // Background
                context.fill(
                    Path(CGRect(origin: .zero, size: size)),
                    with: .color(Constants.backgroundColor)
                )

                // Grid lines
                for i in 0...Constants.gridSize {
                    let pos = CGFloat(i) * cellSize
                    var hLine = Path()
                    hLine.move(to: CGPoint(x: 0, y: pos))
                    hLine.addLine(to: CGPoint(x: size.width, y: pos))
                    context.stroke(hLine, with: .color(Constants.gridLineColor), lineWidth: 0.5)

                    var vLine = Path()
                    vLine.move(to: CGPoint(x: pos, y: 0))
                    vLine.addLine(to: CGPoint(x: pos, y: size.height))
                    context.stroke(vLine, with: .color(Constants.gridLineColor), lineWidth: 0.5)
                }

                // Food with pulsing effect
                let pulse = 0.85 + 0.15 * sin(timeline.date.timeIntervalSinceReferenceDate * 4)
                let foodRect = cellRect(for: game.food, cellSize: cellSize, scale: pulse)
                let foodPath = Path(roundedRect: foodRect, cornerRadius: cellSize * 0.3)
                context.fill(foodPath, with: .color(Constants.foodColor))

                // Snake body (tail to head so head draws on top)
                let count = game.snake.count
                for (index, segment) in game.snake.enumerated().reversed() {
                    let brightness = 1.0 - (Double(index) / Double(max(count, 1))) * 0.5
                    let color: Color
                    if index == 0 {
                        color = Constants.snakeHeadColor
                    } else {
                        color = Constants.snakeBodyColor.opacity(brightness)
                    }

                    let rect = cellRect(for: segment, cellSize: cellSize, scale: 1.0)
                    let insetRect = rect.insetBy(dx: 1, dy: 1)
                    let segmentPath = Path(roundedRect: insetRect, cornerRadius: Constants.cornerRadius)
                    context.fill(segmentPath, with: .color(color))
                }

                // Snake eyes
                if let head = game.snake.first {
                    let headCenter = CGPoint(
                        x: CGFloat(head.x) * cellSize + cellSize / 2,
                        y: CGFloat(head.y) * cellSize + cellSize / 2
                    )
                    let eyeSize: CGFloat = cellSize * 0.18
                    let eyeOffset: CGFloat = cellSize * 0.2

                    let (dx, dy): (CGFloat, CGFloat) = {
                        switch game.direction {
                        case .up: return (eyeOffset, -eyeOffset)
                        case .down: return (eyeOffset, eyeOffset)
                        case .left: return (-eyeOffset, eyeOffset)
                        case .right: return (eyeOffset, eyeOffset)
                        }
                    }()

                    let (perpX, perpY): (CGFloat, CGFloat) = {
                        switch game.direction {
                        case .up, .down: return (1, 0)
                        case .left, .right: return (0, 1)
                        }
                    }()

                    let eye1Center = CGPoint(
                        x: headCenter.x + perpX * eyeOffset * 0.5 + (game.direction == .left || game.direction == .right ? dx * 0.5 : 0),
                        y: headCenter.y + perpY * eyeOffset * 0.5 + (game.direction == .up || game.direction == .down ? dy * 0.5 : 0)
                    )
                    let eye2Center = CGPoint(
                        x: headCenter.x - perpX * eyeOffset * 0.5 + (game.direction == .left || game.direction == .right ? dx * 0.5 : 0),
                        y: headCenter.y - perpY * eyeOffset * 0.5 + (game.direction == .up || game.direction == .down ? dy * 0.5 : 0)
                    )

                    let eye1 = Path(ellipseIn: CGRect(
                        x: eye1Center.x - eyeSize, y: eye1Center.y - eyeSize,
                        width: eyeSize * 2, height: eyeSize * 2
                    ))
                    let eye2 = Path(ellipseIn: CGRect(
                        x: eye2Center.x - eyeSize, y: eye2Center.y - eyeSize,
                        width: eyeSize * 2, height: eyeSize * 2
                    ))

                    context.fill(eye1, with: .color(.white))
                    context.fill(eye2, with: .color(.white))

                    // Pupils
                    let pupilSize = eyeSize * 0.5
                    let pupilOffset: CGFloat = eyeSize * 0.3
                    let (pdx, pdy): (CGFloat, CGFloat) = {
                        switch game.direction {
                        case .up: return (0, -pupilOffset)
                        case .down: return (0, pupilOffset)
                        case .left: return (-pupilOffset, 0)
                        case .right: return (pupilOffset, 0)
                        }
                    }()

                    let pupil1 = Path(ellipseIn: CGRect(
                        x: eye1Center.x + pdx - pupilSize, y: eye1Center.y + pdy - pupilSize,
                        width: pupilSize * 2, height: pupilSize * 2
                    ))
                    let pupil2 = Path(ellipseIn: CGRect(
                        x: eye2Center.x + pdx - pupilSize, y: eye2Center.y + pdy - pupilSize,
                        width: pupilSize * 2, height: pupilSize * 2
                    ))

                    context.fill(pupil1, with: .color(.black))
                    context.fill(pupil2, with: .color(.black))
                }
            }
        }
        .frame(width: boardSize, height: boardSize)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.green.opacity(0.3), lineWidth: 2)
        )
        .gesture(
            DragGesture(minimumDistance: 20)
                .onEnded { value in
                    let horizontal = abs(value.translation.width) > abs(value.translation.height)
                    if horizontal {
                        game.changeDirection(value.translation.width > 0 ? .right : .left)
                    } else {
                        game.changeDirection(value.translation.height > 0 ? .down : .up)
                    }
                }
        )
    }

    private func cellRect(for position: GridPosition, cellSize: CGFloat, scale: Double) -> CGRect {
        let size = cellSize * scale
        let offset = (cellSize - size) / 2
        return CGRect(
            x: CGFloat(position.x) * cellSize + offset,
            y: CGFloat(position.y) * cellSize + offset,
            width: size,
            height: size
        )
    }
}
