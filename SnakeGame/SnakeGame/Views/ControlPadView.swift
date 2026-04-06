import SwiftUI

struct ControlPadView: View {
    let onDirection: (Direction) -> Void

    var body: some View {
        VStack(spacing: 8) {
            arrowButton(direction: .up, icon: "chevron.up")

            HStack(spacing: 40) {
                arrowButton(direction: .left, icon: "chevron.left")
                arrowButton(direction: .right, icon: "chevron.right")
            }

            arrowButton(direction: .down, icon: "chevron.down")
        }
        .padding(.vertical, 12)
    }

    private func arrowButton(direction: Direction, icon: String) -> some View {
        Button {
            onDirection(direction)
        } label: {
            Image(systemName: icon)
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.white)
                .frame(width: 56, height: 56)
                .background(Color.white.opacity(0.12))
                .clipShape(Circle())
        }
    }
}
