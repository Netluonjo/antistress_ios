import SwiftUI

public struct FidgetSpinnerToyView: View {
    @State private var angle: Double = 0
    @State private var velocity: Double = 0
    @State private var lastDragLocation: CGPoint = .zero
    @State private var lastDragTime: TimeInterval = 0
    @State private var lastHapticAngle: Double = 0

    private let soundManager = SoundManager.shared
    private let hapticManager = HapticManager.shared
    private let timer = Timer.publish(every: 1.0 / 60.0, on: .main, in: .common).autoconnect()

    public init() {}

    public var body: some View {
        GeometryReader { geo in
            let center = CGPoint(x: geo.size.width / 2, y: geo.size.height / 2)
            let spinnerRadius: CGFloat = min(geo.size.width * 0.38, 140)

            ZStack {
                Color(hex: "#18181B").ignoresSafeArea()

                // Circular shadow on the desk
                Circle()
                    .fill(Color.black.opacity(0.45))
                    .frame(width: spinnerRadius * 2.2, height: spinnerRadius * 2.2)
                    .blur(radius: 12)
                    .offset(y: 10)

                // The Fidget Spinner body
                ZStack {
                    // 3 Weighted Bearing Lobes
                    ForEach(0..<3) { i in
                        let lobeAngle = Double(i) * (360.0 / 3.0)
                        LobeView(radius: spinnerRadius)
                            .rotationEffect(.degrees(lobeAngle))
                    }

                    // Center Bearing Cap
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [Color(hex: "#38BDF8"), Color(hex: "#0284C7")],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 68, height: 68)
                            .shadow(color: .black.opacity(0.4), radius: 6)

                        Circle()
                            .stroke(Color.white.opacity(0.4), lineWidth: 2)
                            .frame(width: 60, height: 60)

                        Circle()
                            .fill(Color(hex: "#0F172A"))
                            .frame(width: 24, height: 24)
                    }
                }
                .rotationEffect(.degrees(angle))
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            handleDrag(location: value.location, center: center)
                        }
                        .onEnded { _ in
                            lastDragTime = 0
                        }
                )

                VStack {
                    Spacer()
                    Text("Gạt mạnh ngón tay theo vòng tròn để quay tít")
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

    private func handleDrag(location: CGPoint, center: CGPoint) {
        let now = Date().timeIntervalSince1970
        let dx = location.x - center.x
        let dy = location.y - center.y
        let currentTouchAngle = atan2(dy, dx) * 180 / .pi

        if lastDragTime > 0 {
            var delta = currentTouchAngle - (atan2(lastDragLocation.y - center.y, lastDragLocation.x - center.x) * 180 / .pi)
            if delta > 180 { delta -= 360 }
            if delta < -180 { delta += 360 }

            let dt = max(0.001, now - lastDragTime)
            velocity = Double(delta) / dt / 45.0 // Convert to angular velocity
            angle += Double(delta)
        }

        lastDragLocation = location
        lastDragTime = now
    }

    private func updatePhysics() {
        if abs(velocity) > 0.05 {
            angle += velocity
            velocity *= 0.988 // Smooth friction decay

            // Ticking haptic at rotational milestones
            if abs(angle - lastHapticAngle) > 60.0 {
                hapticManager.vibrateClick()
                lastHapticAngle = angle
            }
        } else {
            velocity = 0
        }
    }

    public func reset() {
        velocity = 0
        angle = 0
        hapticManager.vibrateLight()
    }
}

private struct LobeView: View {
    let radius: CGFloat

    var body: some View {
        ZStack {
            // Sleek aerodynamic arm
            Capsule()
                .fill(
                    LinearGradient(
                        colors: [Color(hex: "#0284C7"), Color(hex: "#0369A1"), Color(hex: "#075985")],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 46, height: radius * 1.5)
                .offset(y: -radius * 0.5)

            // Outer steel counterweight bearing
            ZStack {
                Circle()
                    .fill(Color(hex: "#334155"))
                    .frame(width: 52, height: 52)

                Circle()
                    .stroke(
                        LinearGradient(
                            colors: [Color(hex: "#CBD5E1"), Color(hex: "#64748B")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 6
                    )
                    .frame(width: 44, height: 44)

                Circle()
                    .fill(Color(hex: "#0F172A"))
                    .frame(width: 22, height: 22)
            }
            .offset(y: -radius)
        }
    }
}
