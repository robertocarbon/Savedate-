import SwiftUI

struct GameOverView: View {
    let score: Int
    let highScore: Int
    let onRestart: () -> Void
    @State private var appear = false

    var isNewHighScore: Bool { score >= highScore && score > 0 }

    var body: some View {
        ZStack {
            Color.black.opacity(0.75)
                .ignoresSafeArea()

            VStack(spacing: 20) {
                Text("GAME OVER")
                    .font(.system(size: 40, weight: .black, design: .monospaced))
                    .foregroundColor(.red)
                    .shadow(color: .red.opacity(0.5), radius: 8)

                Text("\(score)")
                    .font(.system(size: 64, weight: .bold, design: .monospaced))
                    .foregroundColor(.white)

                if isNewHighScore {
                    Text("NEW HIGH SCORE!")
                        .font(.system(.headline, design: .monospaced))
                        .foregroundColor(.yellow)
                        .shadow(color: .yellow.opacity(0.5), radius: 6)
                }

                Button(action: onRestart) {
                    Text("PLAY AGAIN")
                        .font(.system(.title3, design: .monospaced).bold())
                        .foregroundColor(.black)
                        .padding(.horizontal, 32)
                        .padding(.vertical, 14)
                        .background(Color.green)
                        .cornerRadius(12)
                }
                .padding(.top, 10)
            }
            .scaleEffect(appear ? 1 : 0.5)
            .opacity(appear ? 1 : 0)
            .animation(.spring(response: 0.4, dampingFraction: 0.7), value: appear)
            .onAppear { appear = true }
        }
        .transition(.opacity)
    }
}
