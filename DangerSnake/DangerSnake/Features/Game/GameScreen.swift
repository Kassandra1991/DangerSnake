import SwiftUI

struct GameScreen: View {
    @Bindable var engine: GameEngine
    var onMenu: () -> Void

    var body: some View {
        ZStack {
            Color(red: 0.04, green: 0.07, blue: 0.05).ignoresSafeArea()

            VStack(spacing: 0) {
                topBar
                    .padding(.horizontal)
                    .padding(.top, 8)

                BoardCanvas(engine: engine, onSwipe: { engine.queueDirection($0) })
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(.horizontal, 8)

                Text(engine.status)
                    .font(.footnote)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.white.opacity(0.9))
                    .padding(.horizontal)
                    .padding(.vertical, 6)

                if !engine.isGameOver {
                    DirectionPad(onDirection: { engine.queueDirection($0) })
                        .padding(.bottom, 16)
                } else {
                    Color.clear.frame(height: 16)
                }
            }

            if engine.isGameOver {
                gameOverOverlay
            }
        }
        .onAppear { engine.startMatch() }
        .onDisappear { engine.stop() }
        .statusBarHidden(true)
    }

    private var topBar: some View {
        let _ = engine.renderTick
        return VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text("Score \(engine.score)")
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(.white)
                Spacer()
                if engine.hasShield {
                    Text("SHIELD")
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(Color(red: 0.4, green: 0.75, blue: 1.0))
                }
            }
            Text(engine.appleWeapon.map { "Your weapon: \($0.displayName)" } ?? "You are the apple · unarmed")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.85))
        }
    }

    private var gameOverOverlay: some View {
        VStack(spacing: 12) {
            Text(engine.isVictory ? "Victory!" : "Game Over")
                .font(.title.weight(.bold))
                .foregroundStyle(.white)
            Text(engine.gameOverReason)
                .font(.title3)
                .multilineTextAlignment(.center)
                .foregroundStyle(.white.opacity(0.95))
            Text("Score \(engine.score)")
                .foregroundStyle(.white.opacity(0.9))
            Button("Restart") { engine.restart() }
                .buttonStyle(GameButtonStyle())
            Button("Menu") {
                engine.stop()
                onMenu()
            }
            .buttonStyle(GameButtonStyle(secondary: true))
        }
        .padding(20)
        .frame(maxWidth: 360)
        .background(.black.opacity(0.8), in: RoundedRectangle(cornerRadius: 16))
        .padding()
    }
}
