import SwiftUI

public struct LotusPondToyView: View {
    private struct Ripple: Identifiable {
        let id: UUID = UUID()
        let x: CGFloat
        let y: CGFloat
        var radius: CGFloat = 4
        var opacity: Double = 0.9
    }

    private struct LilyPad: Identifiable {
        let id: Int
        let x: CGFloat
        let y: CGFloat
        let radius: CGFloat
        let rotation: Double
        let hasFlower: Bool
    }

    @State private var ripples: [Ripple] = []
    @State private var koiPos: CGPoint = CGPoint(x: 200, y: 350)
    @State private var koiHeading: Double = 0
    @State private var koiTailAngle: Double = 0
    @State private var targetPos: CGPoint = CGPoint(x: 200, y: 350)

    private let lilyPads: [LilyPad] = [
        LilyPad(id: 0, x: 90, y: 160, radius: 48, rotation: 35, hasFlower: true),
        LilyPad(id: 1, x: 280, y: 220, radius: 42, rotation: 110, hasFlower: false),
        LilyPad(id: 2, x: 80, y: 520, radius: 56, rotation: 210, hasFlower: false),
        LilyPad(id: 3, x: 300, y: 600, radius: 50, rotation: 75, hasFlower: true)
    ]

    private let soundManager = SoundManager.shared
    private let hapticManager = HapticManager.shared
    private let timer = Timer.publish(every: 1.0 / 60.0, on: .main, in: .common).autoconnect()

    public init() {}

    public var body: some View {
        GeometryReader { geo in
            ZStack {
                // Calm deep water gradient
                LinearGradient(
                    colors: [Color(hex: "#0369A1"), Color(hex: "#0284C7"), Color(hex: "#0C4A6E")],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                // Water ripples
                Canvas { context, _ in
                    for ripple in ripples {
                        let rect = CGRect(
                            x: ripple.x - ripple.radius,
                            y: ripple.y - ripple.radius,
                            width: ripple.radius * 2,
                            height: ripple.radius * 2
                        )
                        context.stroke(
                            Path(ellipseIn: rect),
                            with: .color(Color.white.opacity(ripple.opacity)),
                            lineWidth: 2.0
                        )
                    }
                }

                // Swimming Koi Fish
                koiFishView()
                    .position(koiPos)
                    .rotationEffect(.degrees(koiHeading + 90))

                // Floating Lily Pads
                ForEach(lilyPads) { pad in
                    lilyPadView(pad: pad)
                        .position(x: pad.x, y: pad.y)
                }

                VStack {
                    Spacer()
                    Text("Chạm vào mặt nước để tạo gợn sóng và gọi cá Koi")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white.opacity(0.8))
                        .padding(.bottom, 24)
                }
            }
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        addRipple(at: value.location)
                        targetPos = value.location
                    }
            )
            .onReceive(timer) { _ in
                updatePond()
            }
        }
    }

    private func lilyPadView(pad: LilyPad) -> some View {
        ZStack {
            // Shadow under lily pad
            Circle()
                .fill(Color.black.opacity(0.3))
                .frame(width: pad.radius * 2, height: pad.radius * 2)
                .offset(y: 6)

            // Lily Pad leaf with slit
            Circle()
                .fill(
                    LinearGradient(
                        colors: [Color(hex: "#22C55E"), Color(hex: "#15803D"), Color(hex: "#166534")],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: pad.radius * 2, height: pad.radius * 2)
                .overlay(
                    // Notch / Slit
                    TriangleNotch()
                        .fill(Color(hex: "#0284C7"))
                        .frame(width: pad.radius * 0.45, height: pad.radius)
                        .offset(y: -pad.radius * 0.5)
                )
                .rotationEffect(.degrees(pad.rotation))

            // Lotus Flower
            if pad.hasFlower {
                lotusFlower()
                    .offset(x: 12, y: -12)
            }
        }
    }

    private func lotusFlower() -> some View {
        ZStack {
            ForEach(0..<6) { i in
                Capsule()
                    .fill(Color(hex: "#F472B6"))
                    .frame(width: 8, height: 20)
                    .rotationEffect(.degrees(Double(i) * 30))
            }
            Circle()
                .fill(Color(hex: "#FDE047"))
                .frame(width: 10, height: 10)
        }
    }

    private func koiFishView() -> some View {
        ZStack {
            // Fish Shadow
            Capsule()
                .fill(Color.black.opacity(0.25))
                .frame(width: 22, height: 60)
                .offset(x: 4, y: 8)

            // Fish body
            Capsule()
                .fill(
                    LinearGradient(
                        colors: [Color(hex: "#FF6B35"), Color(hex: "#FFFFFF"), Color(hex: "#FF4500")],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 20, height: 56)

            // Black markings
            Circle()
                .fill(Color.black.opacity(0.8))
                .frame(width: 8, height: 8)
                .offset(x: -2, y: -8)

            // Wiggling tail fin
            TriangleNotch()
                .fill(Color(hex: "#FF6B35").opacity(0.85))
                .frame(width: 18, height: 22)
                .offset(y: 36)
                .rotationEffect(.degrees(koiTailAngle))
        }
    }

    private func addRipple(at point: CGPoint) {
        if ripples.count < 10 {
            ripples.append(Ripple(x: point.x, y: point.y))
            soundManager.playWaterDrop()
            hapticManager.vibrateLight()
        }
    }

    private func updatePond() {
        // Update ripples
        for i in ripples.indices.reversed() {
            ripples[i].radius += 2.5
            ripples[i].opacity -= 0.02
            if ripples[i].opacity <= 0 {
                ripples.remove(at: i)
            }
        }

        // Steer Koi fish toward target
        let dx = targetPos.x - koiPos.x
        let dy = targetPos.y - koiPos.y
        let dist = hypot(dx, dy)

        if dist > 15 {
            let desiredAngle = atan2(dy, dx) * 180 / .pi
            koiHeading = desiredAngle
            let speed: CGFloat = min(2.8, dist * 0.04)
            koiPos.x += cos(desiredAngle * .pi / 180) * speed
            koiPos.y += sin(desiredAngle * .pi / 180) * speed
            koiTailAngle = sin(Date().timeIntervalSince1970 * 8.0) * 18.0
        } else {
            koiTailAngle = sin(Date().timeIntervalSince1970 * 3.0) * 8.0
        }
    }

    public func reset() {
        ripples.removeAll()
        targetPos = CGPoint(x: 200, y: 350)
        hapticManager.vibrateLight()
    }
}

private struct TriangleNotch: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
        path.closeSubpath()
        return path
    }
}

