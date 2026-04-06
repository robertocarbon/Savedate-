import SwiftUI

struct ScoreView: View {
    let score: Int
    let highScore: Int

    var body: some View {
        HStack {
            Text("SCORE: \(score)")
                .font(.system(.title3, design: .monospaced).bold())
                .foregroundColor(.white)

            Spacer()

            HStack(spacing: 4) {
                Image(systemName: "trophy.fill")
                    .foregroundColor(.yellow)
                Text("\(highScore)")
                    .font(.system(.title3, design: .monospaced).bold())
                    .foregroundColor(.yellow)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
    }
}
