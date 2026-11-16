import SwiftUI

public struct SlimeToyView: View {
    private struct Node {
        var angle: CGFloat
        var radius: CGFloat
        var velocity: CGFloat = 0
    }

    @State private var nodes: [Node] = []
    @State private var baseRadius: CGFloat = 130
    @State private var center: CGPoint = .zero
    @State private var lastSquishTime: TimeInterval = 0

    private let soundManager = SoundManager.shared
    private let hapticManager = HapticManager.shared
    private let numNodes = 24

    public init() {}

    public var body: some View {
        GeometryReader { geo in
            ZStack {
                Color(hex: "#0F172A").ignoresSafeArea()

                Canvas { context, size in
                    let c = CGPoint(x: size.width / 2, y: size.height / 2)
                    guard nodes.count == numNodes else { return }

                    // Construct smooth path around nodes
                    var points: [CGPoint] = []
                    for node in nodes {
                        let px = c.x + cos(node.angle) * node.radius
                        let py = c.y + sin(node.angle) * node.radius
                        points.append(CGPoint(x: px, y: py))
                    }

                    var slimePath = Path()
                    slimePath.move(to: points[0])
                    for i in 0..<numNodes {
                        let current = points[i]
                        let next = points[(i + 1) % numNodes]
                        let mid = CGPoint(x: (current.x + next.x) / 2, y: (current.y + next.y) / 2)
                        slimePath.addQuadCurve(to: mid, control: current)
                    }
                    slimePath.closeSubpath()

                    // Drop shadow
                    context.fill(
                        slimePath.offsetBy(dx: 0, dy: 16),
                        with: .color(Color.black.opacity(0.35))
                    )

                    // Slime body gradient
                    let gradient = Gradient(colors: [
                        Color(hex: "#4ADE80"), // Emerald glow
                        Color(hex: "#22C55E"), // Lime green
                        Color(hex: "#15803D")  // Deep forest
                    ])
                    context.fill(
                        slimePath,
                        with: .radialGradient(
                            gradient,
                            center: c,
                            startRadiusFraction: 0.1,
                            endRadiusFraction: 1.0
                        )
                    )

                    // Top glossy shine highlight
                    var shinePath = Path()
                    shinePath.addEllipse(in: CGRect(x: c.x - 55, y: c.y - 75, width: 85, height: 42))
                    context.fill(shinePath, with: .color(Color.white.opacity(0.35)))
                }
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            handleTouch(location: value.location, center: CGPoint(x: geo.size.width / 2, y: geo.size.height / 2))
                        }
                )

                // Instruction prompt
                VStack {
                    Spacer()
                    Text("Bóp méo, kéo dãn hoặc ấn vào khối chất nhờn")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white.opacity(0.6))
                        .padding(.bottom, 24)
                }
            }
            .onAppear {
                setupSlime(size: geo.size)
            }
        }
    }

    private func setupSlime(size: CGSize) {
        center = CGPoint(x: size.width / 2, y: size.height / 2)
        baseRadius = min(size.width * 0.35, 140)
        var list: [Node] = []
        for i in 0..<numNodes {
            let angle = (CGFloat.pi * 2 / CGFloat(numNodes)) * CGFloat(i)
            list.append(Node(angle: angle, radius: baseRadius, velocity: 0))
        }
        nodes = list
    }

    private func handleTouch(location: CGPoint, center: CGPoint) {
        let dx = location.x - center.x
        let dy = location.y - center.y
        let touchDist = hypot(dx, dy)
        var touchAngle = atan2(dy, dx)
        if touchAngle < 0 { touchAngle += CGFloat.pi * 2 }

        // Deform nodes based on touch angle
        for i in nodes.indices {
            var diff = abs(nodes[i].angle - touchAngle)
            if diff > CGFloat.pi { diff = CGFloat.pi * 2 - diff }

            if diff < CGFloat.pi / 2.5 {
                let falloff = 1.0 - (diff / (CGFloat.pi / 2.5))
                let targetR = max(baseRadius * 0.5, min(baseRadius * 1.8, touchDist))
                nodes[i].radius = baseRadius + (targetR - baseRadius) * falloff
            } else {
                // Squeeze opposite side
                let stretch = baseRadius * 0.15
                nodes[i].radius = max(baseRadius * 0.6, baseRadius - stretch)
            }
        }

        let now = Date().timeIntervalSince1970
        if now - lastSquishTime > 0.18 {
            soundManager.playSquish()
            hapticManager.vibrateSoft()
            lastSquishTime = now
        }

        // Return to normal shape smoothly
        withAnimation(.interpolatingSpring(stiffness: 140, damping: 9)) {
            for i in nodes.indices {
                nodes[i].radius = baseRadius
            }
        }
    }

    public func reset() {
        for i in nodes.indices {
            nodes[i].radius = baseRadius
            nodes[i].velocity = 0
        }
        hapticManager.vibrateLight()
    }
}
