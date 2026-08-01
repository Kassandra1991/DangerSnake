import SwiftUI

struct MenuView: View {
    var onPlay: () -> Void

    var body: some View {
        ZStack {
            Color(red: 0.05, green: 0.10, blue: 0.07).ignoresSafeArea()

            VStack(spacing: 24) {
                Spacer()
                Text("DangerSnake")
                    .font(.system(size: 44, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)

                Text("You are the apple.\nFlee the AI snake, grab weapons, fight back.")
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.white.opacity(0.85))

                Button("Play", action: onPlay)
                    .buttonStyle(GameButtonStyle())
                    .frame(maxWidth: 280)
                    .padding(.top, 12)

                Spacer()

                Text("Swipe the board or use on-screen arrows")
                    .font(.footnote)
                    .foregroundStyle(.white.opacity(0.6))
                    .padding(.bottom, 24)
            }
            .padding()
        }
    }
}
