import SwiftUI

struct ContentView: View {
    @StateObject private var game = GameState()
    @StateObject private var folderManager = FolderAccessManager.shared
    @State private var showSettings = false

    var body: some View {
        GeometryReader { geo in
            let boardSize = min(geo.size.width - 32, geo.size.height - 280)

            ZStack {
                Constants.backgroundColor
                    .ignoresSafeArea()

                VStack(spacing: 12) {
                    HStack {
                        ScoreView(score: game.score, highScore: game.highScore)
                        Button(action: {
                            if game.gamePhase == .playing {
                                game.pauseGame()
                            }
                            showSettings = true
                        }) {
                            Image(systemName: "gearshape.fill")
                                .font(.title3)
                                .foregroundColor(.gray)
                                .padding(.trailing, 16)
                        }
                    }

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
        .fullScreenCover(isPresented: $showSettings, onDismiss: {
            if game.gamePhase == .playing {
                game.resumeGame()
            }
        }) {
            SettingsView(folderManager: folderManager)
        }
    }
}
