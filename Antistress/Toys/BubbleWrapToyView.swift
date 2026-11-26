import SwiftUI

public struct BubbleWrapToyView: View {
    struct Bubble: Identifiable {
        let id: Int
        var x: CGFloat
        var y: CGFloat
        var radius: CGFloat
        var isPopped: Bool = false
    }

    @State private var bubbles: [Bubble] = []
    @State private var size: CGSize = .zero
    private let soundManager = SoundManager.shared
    private let hapticManager = HapticManager.shared

    public init() {}

    public var body: some View {
        GeometryReader { geo in
            ZStack {
                Color(hex: "#E0F2F1").ignoresSafeArea()

                Canvas { context, canvasSize in
                    for bubble in bubbles {
                        let rect = CGRect(
                            x: bubble.x - bubble.radius,
                            y: bubble.y - bubble.radius,
                            width: bubble.radius * 2,
                            height: bubble.radius * 2
                        )

                        if bubble.isPopped {
                            // Popped deflated ring
                            context.fill(
                                Path(ellipseIn: rect.insetBy(dx: 4, dy: 4)),
                                with: .color(Color(hex: "#B2DFDB"))
                            )
                            // Wrinkle folds
                            var fold = Path()
                            fold.move(to: CGPoint(x: bubble.x - bubble.radius * 0.4, y: bubble.y - bubble.radius * 0.3))
                            fold.addLine(to: CGPoint(x: bubble.x + bubble.radius * 0.3, y: bubble.y + bubble.radius * 0.4))
                            fold.move(to: CGPoint(x: bubble.x - bubble.radius * 0.2, y: bubble.y + bubble.radius * 0.4))
                            fold.addLine(to: CGPoint(x: bubble.x + bubble.radius * 0.4, y: bubble.y - bubble.radius * 0.2))
                            context.stroke(fold, with: .color(Color(hex: "#80CBC4")), lineWidth: 2)
                        } else {
                            // Outer soft shadow
                            let shadowRect = rect.offsetBy(dx: 2, dy: 4)
                            context.fill(Path(ellipseIn: shadowRect), with: .color(Color.black.opacity(0.12)))

                            // Glossy dome
                            let gradient = Gradient(colors: [
                                Color.white.opacity(0.85),
                                Color(hex: "#4DD0E1").opacity(0.4),
                                Color(hex: "#00ACC1").opacity(0.7)
                            ])
                            context.fill(
                                Path(ellipseIn: rect),
                                with: .radialGradient(
                                    gradient,
                                    center: CGPoint(x: bubble.x - bubble.radius * 0.3, y: bubble.y - bubble.radius * 0.3),
                                    startRadius: bubble.radius * 0.05,
                                    endRadius: bubble.radius
                                )
                            )

                            // Glass highlight crescent
                            let highlightRect = CGRect(
                                x: bubble.x - bubble.radius * 0.65,
                                y: bubble.y - bubble.radius * 0.65,
                                width: bubble.radius * 0.6,
                                height: bubble.radius * 0.35
                            )
                            context.fill(Path(ellipseIn: highlightRect), with: .color(Color.white.opacity(0.85)))
                        }
                    }
                }
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            popBubbleAt(value.location)
                        }
                )
            }
            .onAppear {
                setupBubbles(size: geo.size)
            }
            .onChange(of: geo.size) { newSize in
                setupBubbles(size: newSize)
            }
        }
    }

    private func setupBubbles(size: CGSize) {
        guard size.width > 0 && size.height > 0 else { return }
        self.size = size
        var list: [Bubble] = []
        let cols = 6
        let spacing = size.width / CGFloat(cols)
        let radius = spacing * 0.42
        let rows = Int(size.height / spacing) + 2
        var idCounter = 0

        for r in 0..<rows {
            let offset = (r % 2 == 1) ? spacing * 0.5 : 0.0
            for c in 0...cols {
                let cx = CGFloat(c) * spacing + offset
                let cy = spacing * 0.6 + CGFloat(r) * (spacing * 0.88)
                list.append(Bubble(id: idCounter, x: cx, y: cy, radius: radius))
                idCounter += 1
            }
        }
        self.bubbles = list
    }

    private func popBubbleAt(_ point: CGPoint) {
        for i in bubbles.indices {
            let b = bubbles[i]
            if !b.isPopped {
                let dx = point.x - b.x
                let dy = point.y - b.y
                if hypot(dx, dy) <= b.radius {
                    bubbles[i].isPopped = true
                    soundManager.playPop()
                    hapticManager.vibratePop()
                    break
                }
            }
        }
    }

    public func reset() {
        for i in bubbles.indices {
            bubbles[i].isPopped = false
        }
        hapticManager.vibrateLight()
    }
}

