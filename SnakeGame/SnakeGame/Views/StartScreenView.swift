import SwiftUI

struct StartScreenView: View {
    let onStart: () -> Void
    @State private var pulse = false

    var body: some View {
        ZStack {
            Color.black.opacity(0.75)
                .ignoresSafeArea()

            VStack(spacing: 30) {
                Text("SNAKE")
                    .font(.system(size: 56, weight: .black, design: .monospaced))
                    .foregroundColor(.green)
                    .shadow(color: .green.opacity(0.6), radius: 10)

                Text("Swipe or use arrows to move")
                    .font(.system(.body, design: .monospaced))
                    .foregroundColor(.gray)

                Button(action: onStart) {
                    Text("TAP TO PLAY")
                        .font(.system(.title2, design: .monospaced).bold())
                        .foregroundColor(.black)
                        .padding(.horizontal, 32)
                        .padding(.vertical, 16)
                        .background(Color.green)
                        .cornerRadius(12)
                }
                .opacity(pulse ? 0.6 : 1.0)
                .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: pulse)
                .onAppear { pulse = true }
            }
        }
        .transition(.opacity)
    }
}
