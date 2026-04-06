import Foundation

struct GridPosition: Equatable, Hashable {
    let x: Int
    let y: Int

    func moved(in direction: Direction) -> GridPosition {
        let d = direction.delta
        return GridPosition(x: x + d.dx, y: y + d.dy)
    }
}
