import SwiftUI

struct ContentView: View {
    @StateObject private var game = GameState()

    var body: some View {
        GeometryReader { geo in
            let boardSize = min(geo.size.width - 32, geo.size.height - 280)

            ZStack {
                Constants.backgroundColor
                    .ignoresSafeArea()

                VStack(spacing: 12) {
                    ScoreView(score: game.score, highScore: game.highScore)

                    GameBoardView(game: game, boardSize: boardSize)

                    ControlPadView(onDirection: { direction in
                        game.changeDirection(direction)
                    })

                    Spacer()
                }
                .padding(.top, 8)

                if game.gamePhase == .notStarted {
                    StartScreenView(onStart: { game.startGame() })
                }

                if game.gamePhase == .gameOver {
                    GameOverView(
                        score: game.score,
                        highScore: game.highScore,
                        onRestart: { game.startGame() }
                    )
                }
            }
        }
        .statusBarHidden()
    }
}
