import SwiftUI

public struct NewtonsCradleToyView: View {
    private final class Ball: ObservableObject {
        let index: Int
        var anchorX: CGFloat = 0
        var anchorY: CGFloat = 0
        var stringLength: CGFloat = 0
        var radius: CGFloat = 0

        var theta: CGFloat = 0
        var omega: CGFloat = 0

        var isDragging: Bool = false
        var currentX: CGFloat = 0
        var currentY: CGFloat = 0

        init(index: Int) {
            self.index = index
        }

        func updatePos() {
            currentX = anchorX + stringLength * sin(theta)
            currentY = anchorY + stringLength * cos(theta)
        }
    }

    @State private var balls: [Ball] = (0..<5).map { Ball(index: $0) }
    @State private var activeDragIndex: Int? = nil
    @State private var viewSize: CGSize = .zero

    private let soundManager = SoundManager.shared
    private let hapticManager = HapticManager.shared
    private let timer = Timer.publish(every: 1.0 / 60.0, on: .main, in: .common).autoconnect()

    public init() {}

    public var body: some View {
        GeometryReader { geo in
            ZStack {
                Color(hex: "#1E1B18").ignoresSafeArea()

                Canvas { context, size in
                    let frameY = size.height * 0.22

                    // Top Chrome Bar
                    let barRect = CGRect(x: size.width * 0.15, y: frameY - 6, width: size.width * 0.7, height: 12)
                    context.fill(Path(roundedRect: barRect, cornerRadius: 6), with: .color(Color(hex: "#94A3B8")))

                    for ball in balls {
                        // Shadow
                        let shadowY = frameY + ball.stringLength + ball.radius + 40
                        let shadowRect = CGRect(
                            x: ball.currentX - ball.radius * 0.8,
                            y: shadowY,
                            width: ball.radius * 1.6,
                            height: 12
                        )
                        context.fill(Path(ellipseIn: shadowRect), with: .color(Color.black.opacity(0.35)))

                        // Strings (V shape from anchor to ball)
                        var str = Path()
                        str.move(to: CGPoint(x: ball.anchorX - 10, y: frameY))
                        str.addLine(to: CGPoint(x: ball.currentX, y: ball.currentY - ball.radius))
                        str.move(to: CGPoint(x: ball.anchorX + 10, y: frameY))
                        str.addLine(to: CGPoint(x: ball.currentX, y: ball.currentY - ball.radius))
                        context.stroke(str, with: .color(Color(hex: "#CBD5E1").opacity(0.7)), lineWidth: 1.5)

                        // Steel Ball with mirror shine
                        let bRect = CGRect(
                            x: ball.currentX - ball.radius,
                            y: ball.currentY - ball.radius,
                            width: ball.radius * 2,
                            height: ball.radius * 2
                        )
                        let gradient = Gradient(colors: [
                            Color(hex: "#FFFFFF"),
                            Color(hex: "#CBD5E1"),
                            Color(hex: "#64748B"),
                            Color(hex: "#1E293B")
                        ])
                        context.fill(
                            Path(ellipseIn: bRect),
                            with: .radialGradient(
                                gradient,
                                center: CGPoint(x: ball.currentX - ball.radius * 0.35, y: ball.currentY - ball.radius * 0.35),
                                startRadiusFraction: 0.05,
                                endRadiusFraction: 1.0
                            )
                        )
                    }
                }
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            handleDrag(at: value.location)
                        }
                        .onEnded { _ in
                            if let idx = activeDragIndex {
                                balls[idx].isDragging = false
                                activeDragIndex = nil
                            }
                        }
                )

                VStack {
                    Spacer()
                    Text("Kéo quả cầu thép ở 2 đầu rồi thả tay ra")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white.opacity(0.6))
                        .padding(.bottom, 24)
                }
            }
            .onAppear {
                setupBalls(size: geo.size)
            }
            .onReceive(timer) { _ in
                simulatePhysics()
            }
        }
    }

    private func setupBalls(size: CGSize) {
        viewSize = size
        let ballDiameter = min(size.width * 0.12, 54)
        let ballRadius = ballDiameter / 2
        let stringLen = size.height * 0.44
        let startY = size.height * 0.22
        let centerX = size.width / 2

        for i in 0..<5 {
            let offsetIndex = CGFloat(i) - 2.0
            let anchorX = centerX + offsetIndex * ballDiameter
            let b = balls[i]
            b.anchorX = anchorX
            b.anchorY = startY
            b.stringLength = stringLen
            b.radius = ballRadius
            b.theta = 0
            b.omega = 0
            b.updatePos()
        }
    }

    private func handleDrag(at point: CGPoint) {
        if activeDragIndex == nil {
            // Find closest ball
            for b in balls {
                let dist = hypot(point.x - b.currentX, point.y - b.currentY)
                if dist < b.radius * 2.5 {
                    activeDragIndex = b.index
                    b.isDragging = true
                    b.omega = 0
                    break
                }
            }
        }

        if let idx = activeDragIndex {
            let b = balls[idx]
            let dx = point.x - b.anchorX
            let dy = max(10, point.y - b.anchorY)
            var angle = atan2(dx, dy)
            // Limit max angle
            angle = max(-CGFloat.pi * 0.38, min(CGFloat.pi * 0.38, angle))
            b.theta = angle
            b.updatePos()
        }
    }

    private func simulatePhysics() {
        let dt: CGFloat = 0.016
        let g: CGFloat = 38.0
        var maxImpact: CGFloat = 0

        for b in balls {
            if !b.isDragging {
                let alpha = -(g / (b.stringLength / 50.0)) * sin(b.theta)
                b.omega += alpha * dt
                b.omega *= 0.9985 // Damping
                b.theta += b.omega * dt
                b.updatePos()
            }
        }

        // Collision detection between adjacent balls
        for i in 0..<4 {
            let b1 = balls[i]
            let b2 = balls[i + 1]

            let dx = b2.currentX - b1.currentX
            let minDist = b1.radius + b2.radius

            if dx < minDist {
                let relVel = b1.omega - b2.omega
                if relVel > 0 {
                    // Elastic collision momentum transfer
                    let v1 = b1.omega
                    let v2 = b2.omega
                    b1.omega = v2 * 0.96
                    b2.omega = v1 * 0.96

                    let impactSpeed = abs(relVel)
                    if impactSpeed > maxImpact {
                        maxImpact = impactSpeed
                    }

                    // Separation to prevent sticking
                    let overlap = (minDist - dx) / b1.stringLength
                    b1.theta -= overlap * 0.5
                    b2.theta += overlap * 0.5
                    b1.updatePos()
                    b2.updatePos()
                }
            }
        }

        if maxImpact > 0.08 {
            let velRatio = Float(min(1.0, maxImpact / 2.2))
            soundManager.playBallImpact(velocityRatio: velRatio)
            hapticManager.vibrateBallImpact(velocityRatio: velRatio)
        }
    }

    public func reset() {
        for b in balls {
            b.theta = 0
            b.omega = 0
            b.isDragging = false
            b.updatePos()
        }
        activeDragIndex = nil
        hapticManager.vibrateLight()
    }
}

