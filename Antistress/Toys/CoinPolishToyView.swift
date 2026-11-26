import SwiftUI

public struct CoinPolishToyView: View {
    private struct PolishScratch: Identifiable {
        let id: UUID = UUID()
        var points: [CGPoint]
    }

    @State private var scratches: [PolishScratch] = []
    @State private var currentPoints: [CGPoint] = []
    @State private var polishPercent: Int = 0
    @State private var hasPlayedSparkle: Bool = false

    private let soundManager = SoundManager.shared
    private let hapticManager = HapticManager.shared

    public init() {}

    public var body: some View {
        GeometryReader { geo in
            let center = CGPoint(x: geo.size.width / 2, y: geo.size.height / 2)
            let coinRadius: CGFloat = min(geo.size.width * 0.38, 140)

            ZStack {
                // Dark velvet jeweler table
                Color(hex: "#1E1B18").ignoresSafeArea()

                VStack(spacing: 24) {
                    // Header progress
                    HStack {
                        Text("Độ bóng sáng: \(polishPercent)%")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundColor(Color(hex: "#FDE047"))

                        if polishPercent >= 90 {
                            Image(systemName: "sparkles")
                                .foregroundColor(Color(hex: "#FDE047"))
                        }
                    }
                    .padding(.top, 24)

                    Spacer()

                    // The Coin View
                    ZStack {
                        // Cast shadow
                        Circle()
                            .fill(Color.black.opacity(0.45))
                            .frame(width: coinRadius * 2.1, height: coinRadius * 2.1)
                            .offset(y: 8)

                        // 1. Polished Gold Coin (Underneath)
                        ZStack {
                            Circle()
                                .fill(
                                    RadialGradient(
                                        colors: [Color(hex: "#FEF08A"), Color(hex: "#EAB308"), Color(hex: "#CA8A04"), Color(hex: "#854D0E")],
                                        center: .center,
                                        startRadius: coinRadius * 0.1,
                                        endRadius: coinRadius
                                    )
                                )
                                .frame(width: coinRadius * 2, height: coinRadius * 2)

                            // Coin beaded border
                            Circle()
                                .stroke(Color(hex: "#FEF08A"), style: StrokeStyle(lineWidth: 3, dash: [4, 4]))
                                .frame(width: coinRadius * 1.85, height: coinRadius * 1.85)

                            // Ancient Sun / Emblem relief
                            VStack(spacing: 6) {
                                Image(systemName: "sun.max.fill")
                                    .font(.system(size: 54))
                                    .foregroundColor(Color(hex: "#FEF08A").opacity(0.85))

                                Text("LIBERTAS")
                                    .font(.system(size: 13, weight: .black, design: .serif))
                                    .foregroundColor(Color(hex: "#FEF08A").opacity(0.8))
                                    .tracking(4)
                            }
                        }

                        // 2. Oxidized Grime Layer (Masked out by scrub scratches)
                        Canvas { context, _ in
                            // Dark oxide layer
                            let cRect = CGRect(
                                x: center.x - coinRadius,
                                y: center.y - coinRadius,
                                width: coinRadius * 2,
                                height: coinRadius * 2
                            )
                            context.fill(Path(ellipseIn: cRect), with: .color(Color(hex: "#3F2E23").opacity(0.92)))

                            // Mask away where rubbed
                            context.blendMode = .clear

                            for scratch in scratches {
                                var path = Path()
                                if let first = scratch.points.first {
                                    path.move(to: first)
                                    for pt in scratch.points.dropFirst() {
                                        path.addLine(to: pt)
                                    }
                                }
                                context.stroke(path, with: .color(.black), style: StrokeStyle(lineWidth: 38, lineCap: .round, lineJoin: .round))
                            }

                            if let first = currentPoints.first {
                                var path = Path()
                                path.move(to: first)
                                for pt in currentPoints.dropFirst() {
                                    path.addLine(to: pt)
                                }
                                context.stroke(path, with: .color(.black), style: StrokeStyle(lineWidth: 38, lineCap: .round, lineJoin: .round))
                            }
                        }
                        .compositingGroup()
                    }
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { value in
                                let dist = hypot(value.location.x - center.x, value.location.y - center.y)
                                if dist <= coinRadius * 1.05 {
                                    currentPoints.append(value.location)
                                    if currentPoints.count % 6 == 0 {
                                        hapticManager.vibrateLight()
                                    }
                                }
                            }
                            .onEnded { _ in
                                if !currentPoints.isEmpty {
                                    scratches.append(PolishScratch(points: currentPoints))
                                    currentPoints = []
                                    calculatePolishProgress()
                                }
                            }
                    )

                    Spacer()

                    Text("Dùng ngón tay chà sát để đánh bóng đồng xu vàng")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white.opacity(0.6))
                        .padding(.bottom, 24)
                }
            }
        }
    }

    private func calculatePolishProgress() {
        let totalScratches = scratches.reduce(0) { $0 + $1.points.count }
        let percent = min(100, Int((Double(totalScratches) / 220.0) * 100))
        polishPercent = percent

        if percent >= 90 && !hasPlayedSparkle {
            hasPlayedSparkle = true
            soundManager.playSparkle()
            hapticManager.vibrateSuccess()
        }
    }

    public func reset() {
        scratches.removeAll()
        currentPoints.removeAll()
        polishPercent = 0
        hasPlayedSparkle = false
        hapticManager.vibrateLight()
    }
}

