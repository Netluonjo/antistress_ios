import SwiftUI

public struct BambooChimesToyView: View {
    private final class ChimeTube: ObservableObject, Identifiable {
        let id: Int
        let length: CGFloat
        let width: CGFloat
        let anchorXRatio: CGFloat
        var angle: CGFloat = 0
        var angularVelocity: CGFloat = 0

        init(id: Int, length: CGFloat, width: CGFloat, anchorXRatio: CGFloat) {
            self.id = id
            self.length = length
            self.width = width
            self.anchorXRatio = anchorXRatio
        }
    }

    @State private var tubes: [ChimeTube] = [
        ChimeTube(id: 0, length: 280, width: 28, anchorXRatio: 0.18),
        ChimeTube(id: 1, length: 340, width: 32, anchorXRatio: 0.34),
        ChimeTube(id: 2, length: 400, width: 34, anchorXRatio: 0.50),
        ChimeTube(id: 3, length: 320, width: 30, anchorXRatio: 0.66),
        ChimeTube(id: 4, length: 260, width: 28, anchorXRatio: 0.82)
    ]

    private let soundManager = SoundManager.shared
    private let hapticManager = HapticManager.shared
    private let timer = Timer.publish(every: 1.0 / 60.0, on: .main, in: .common).autoconnect()

    public init() {}

    public var body: some View {
        GeometryReader { geo in
            ZStack {
                // Calming zen tea room background
                Color(hex: "#1C1917").ignoresSafeArea()

                VStack(spacing: 0) {
                    // Wooden Top Beam
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color(hex: "#78350F"))
                        .frame(height: 16)
                        .padding(.horizontal, 24)
                        .shadow(color: .black.opacity(0.4), radius: 4, y: 3)
                        .padding(.top, 40)

                    Spacer()
                }

                // Hanging tubes
                ForEach(tubes) { tube in
                    let anchorX = geo.size.width * tube.anchorXRatio
                    tubeView(tube: tube)
                        .position(x: anchorX, y: 56 + tube.length / 2)
                        .rotationEffect(.degrees(Double(tube.angle)), anchor: .top)
                }
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            handleSwipe(at: value.location, width: geo.size.width)
                        }
                )

                VStack {
                    Spacer()
                    Text("Vuốt ngang các ống tre để lắng nghe chuông gió")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white.opacity(0.6))
                        .padding(.bottom, 24)
                }
            }
            .onReceive(timer) { _ in
                updatePhysics()
            }
        }
    }

    private func tubeView(tube: ChimeTube) -> some View {
        ZStack(alignment: .top) {
            // Suspension string
            Rectangle()
                .fill(Color(hex: "#D6D3D1"))
                .frame(width: 2, height: 30)

            // Bamboo stalk
            ZStack {
                // Cylindrical Bamboo body
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: "#D4A373"), Color(hex: "#BC6C25"), Color(hex: "#8C4A19")],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: tube.width, height: tube.length)
                    .shadow(color: .black.opacity(0.35), radius: 6, x: 2, y: 4)

                // Bamboo joints / rings
                VStack {
                    Spacer().frame(height: tube.length * 0.3)
                    bambooNode(width: tube.width)
                    Spacer().frame(height: tube.length * 0.35)
                    bambooNode(width: tube.width)
                    Spacer()
                }
                .frame(height: tube.length)

                // Angled cutout at bottom
                VStack {
                    Spacer()
                    Circle()
                        .fill(Color(hex: "#431407"))
                        .frame(width: tube.width * 0.8, height: 10)
                        .offset(y: -4)
                }
            }
            .offset(y: 30)
        }
    }

    private func bambooNode(width: CGFloat) -> some View {
        ZStack {
            Capsule()
                .fill(Color(hex: "#5C2A0A"))
                .frame(width: width + 4, height: 4)
            Capsule()
                .fill(Color(hex: "#FAEDCD").opacity(0.4))
                .frame(width: width + 4, height: 1.5)
                .offset(y: -1)
        }
    }

    private func handleSwipe(at point: CGPoint, width: CGFloat) {
        for tube in tubes {
            let anchorX = width * tube.anchorXRatio
            if abs(point.x - anchorX) < tube.width * 1.5 && point.y > 60 && point.y < 60 + tube.length {
                if abs(tube.angularVelocity) < 2.0 {
                    let direction: CGFloat = point.x > anchorX ? 8.0 : -8.0
                    tube.angularVelocity = direction
                    soundManager.playBambooChime()
                    hapticManager.vibrateLight()
                }
            }
        }
    }

    private func updatePhysics() {
        for tube in tubes {
            if abs(tube.angle) > 0.1 || abs(tube.angularVelocity) > 0.1 {
                let springForce = -tube.angle * 0.08
                tube.angularVelocity += springForce
                tube.angularVelocity *= 0.965 // Damping
                tube.angle += tube.angularVelocity
            } else {
                tube.angle = 0
                tube.angularVelocity = 0
            }
        }
    }

    public func reset() {
        for tube in tubes {
            tube.angle = 0
            tube.angularVelocity = 0
        }
        hapticManager.vibrateLight()
    }
}
