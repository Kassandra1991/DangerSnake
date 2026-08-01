import SwiftUI

struct SwipeDirectionGesture: ViewModifier {
    let onSwipe: (GridPos) -> Void
    private let minDistance: CGFloat = 40

    func body(content: Content) -> some View {
        content.gesture(
            DragGesture(minimumDistance: minDistance)
                .onEnded { value in
                    let dx = value.translation.width
                    let dy = value.translation.height
                    if abs(dx) > abs(dy) {
                        onSwipe(dx > 0 ? Directions.right : Directions.left)
                    } else {
                        // SwiftUI Y grows downward; invert so swipe-up = grid up
                        onSwipe(dy < 0 ? Directions.up : Directions.down)
                    }
                }
        )
    }
}

extension View {
    func onSwipeDirection(_ handler: @escaping (GridPos) -> Void) -> some View {
        modifier(SwipeDirectionGesture(onSwipe: handler))
    }
}
