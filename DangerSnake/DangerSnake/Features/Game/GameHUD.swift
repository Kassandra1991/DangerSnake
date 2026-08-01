import SwiftUI

struct GameHUD: View {
    let score: Int
    let hasShield: Bool
    let appleWeapon: ItemType?
    let status: String
    let isGameOver: Bool
    let isVictory: Bool
    let gameOverReason: String
    let renderTick: UInt64
    let onRestart: () -> Void
    let onMenu: () -> Void
    let onDirection: (GridPos) -> Void

    var body: some View {
        let _ = renderTick

        VStack(spacing: 8) {
            HStack {
                Text("Score \(score)")
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(.white)
                Spacer()
                if hasShield {
                    Text("SHIELD")
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(Color(red: 0.4, green: 0.75, blue: 1.0))
                }
            }

            Text(appleWeapon.map { "Your weapon: \($0.displayName)" } ?? "You are the apple · unarmed")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.85))

            Spacer()

            Text(status)
                .font(.footnote)
                .multilineTextAlignment(.center)
                .foregroundStyle(.white.opacity(0.9))
                .padding(.horizontal)

            if !isGameOver {
                DirectionPad(onDirection: onDirection)
                    .padding(.bottom, 8)
            }

            if isGameOver {
                VStack(spacing: 12) {
                    Text(isVictory ? "Victory!" : "Game Over")
                        .font(.title.weight(.bold))
                        .foregroundStyle(.white)
                    Text(gameOverReason)
                        .font(.title3)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.white.opacity(0.95))
                    Text("Score \(score)")
                        .foregroundStyle(.white.opacity(0.9))
                    Button("Restart", action: onRestart)
                        .buttonStyle(GameButtonStyle())
                    Button("Menu", action: onMenu)
                        .buttonStyle(GameButtonStyle(secondary: true))
                }
                .padding(20)
                .frame(maxWidth: 360)
                .background(.black.opacity(0.75), in: RoundedRectangle(cornerRadius: 16))
            }
        }
        .padding()
    }
}

struct DirectionPad: View {
    let onDirection: (GridPos) -> Void

    var body: some View {
        VStack(spacing: 6) {
            padButton("↑") { onDirection(Directions.up) }
            HStack(spacing: 6) {
                padButton("←") { onDirection(Directions.left) }
                padButton("↓") { onDirection(Directions.down) }
                padButton("→") { onDirection(Directions.right) }
            }
        }
    }

    private func padButton(_ title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.title2.weight(.bold))
                .foregroundStyle(.white)
                .frame(width: 56, height: 44)
                .background(Color.white.opacity(0.14), in: RoundedRectangle(cornerRadius: 10))
                .contentShape(Rectangle())
        }
        .buttonStyle(.borderless)
    }
}

struct GameButtonStyle: ButtonStyle {
    var secondary = false

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                secondary
                    ? Color.white.opacity(0.15)
                    : Color(red: 0.15, green: 0.45, blue: 0.28),
                in: RoundedRectangle(cornerRadius: 12)
            )
            .opacity(configuration.isPressed ? 0.85 : 1)
    }
}
