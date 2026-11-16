import SwiftUI

public struct ZenGardenToyView: View {
    private struct RakeLine: Identifiable {
        let id: UUID = UUID()
        var points: [CGPoint]
    }

    private struct Stone: Identifiable {
        let id: Int
        let x: CGFloat
        let y: CGFloat
        let radiusX: CGFloat
        let radiusY: CGFloat
        let colorHex: String
        let rotation: Double
    }

    @State private var rakeLines: [RakeLine] = []
    @State private var currentPoints: [CGPoint] = []

    private let stones: [Stone] = [
        Stone(id: 0, x: 90, y: 180, radiusX: 36, radiusY: 26, colorHex: "#374151", rotation: 25),
        Stone(id: 1, x: 260, y: 340, radiusX: 42, radiusY: 32, colorHex: "#1F2937", rotation: -15),
        Stone(id: 2, x: 120, y: 520, radiusX: 30, radiusY: 22, colorHex: "#4B5563", rotation: 40)
    ]

    private let soundManager = SoundManager.shared
    private let hapticManager = HapticManager.shared

    public init() {}

    public var body: some View {
        ZStack {
            // Dark Cedar wood frame
            Color(hex: "#29150B").ignoresSafeArea()

            VStack {
                // Sand tray
                ZStack {
                    // Fine White Sand base
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(hex: "#F5F5F0"))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color(hex: "#451A03"), lineWidth: 14)
                        )
                        .shadow(color: .black.opacity(0.5), radius: 12)

                    // Sand rake groove Canvas
                    Canvas { context, _ in
                        for line in rakeLines {
                            drawGrooves(context: &context, points: line.points)
                        }

                        if !currentPoints.isEmpty {
                            drawGrooves(context: &context, points: currentPoints)
                        }
                    }

                    // River stones with shadows
                    ForEach(stones) { stone in
                        stoneView(stone: stone)
                            .position(x: stone.x, y: stone.y)
                    }
                }
                .padding(20)
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            currentPoints.append(value.location)
                            if currentPoints.count % 8 == 0 {
                                soundManager.playSandRake()
                                hapticManager.vibrateClick()
                            }
                        }
                        .onEnded { _ in
                            if !currentPoints.isEmpty {
                                rakeLines.append(RakeLine(points: currentPoints))
                                currentPoints = []
                            }
                        }
                )

                Text("Cào cát trắng để tạo hoa văn thư giãn tâm trí")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white.opacity(0.6))
                    .padding(.bottom, 24)
            }
        }
    }

    private func drawGrooves(context: inout GraphicsContext, points: [CGPoint]) {
        guard let first = points.first else { return }

        // Multi-ridge rake effect (3 parallel grooves)
        let offsets: [CGFloat] = [-8, 0, 8]
        for off in offsets {
            var path = Path()
            path.move(to: CGPoint(x: first.x + off, y: first.y + off))
            for pt in points.dropFirst() {
                path.addLine(to: CGPoint(x: pt.x + off, y: pt.y + off))
            }

            // Outer shadow groove
            context.stroke(
                path,
                with: .color(Color(hex: "#E5E5DE")),
                style: StrokeStyle(lineWidth: 12, lineCap: .round, lineJoin: .round)
            )

            // Inner groove line
            context.stroke(
                path,
                with: .color(Color(hex: "#D4D4C8")),
                style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round)
            )
        }
    }

    private func stoneView(stone: Stone) -> some View {
        ZStack {
            // Shadow
            Ellipse()
                .fill(Color.black.opacity(0.3))
                .frame(width: stone.radiusX * 2, height: stone.radiusY * 2)
                .offset(y: 4)

            // River Stone
            Ellipse()
                .fill(
                    LinearGradient(
                        colors: [Color(hex: stone.colorHex), Color.black.opacity(0.8)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: stone.radiusX * 2, height: stone.radiusY * 2)
                .overlay(
                    // Soft specular highlight on top
                    Ellipse()
                        .fill(Color.white.opacity(0.2))
                        .frame(width: stone.radiusX * 0.7, height: stone.radiusY * 0.4)
                        .offset(x: -stone.radiusX * 0.2, y: -stone.radiusY * 0.3)
                )
        }
        .rotationEffect(.degrees(stone.rotation))
    }

    public func reset() {
        rakeLines.removeAll()
        currentPoints.removeAll()
        hapticManager.vibrateLight()
    }
}

