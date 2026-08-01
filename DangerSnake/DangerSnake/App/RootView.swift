import SwiftUI

enum AppRoute: Equatable {
    case menu
    case game
}

struct RootView: View {
    @State private var route: AppRoute = .menu
    @State private var engine = GameEngine()

    var body: some View {
        Group {
            switch route {
            case .menu:
                MenuView {
                    route = .game
                }
            case .game:
                GameScreen(engine: engine) {
                    route = .menu
                }
            }
        }
        .animation(.easeInOut(duration: 0.2), value: route)
    }
}
