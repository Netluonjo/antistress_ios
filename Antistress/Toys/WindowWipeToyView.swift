import SwiftUI

public struct WindowWipeToyView: View {
    private struct WipeLine: Identifiable {
        let id: UUID = UUID()
        var points: [CGPoint]
    }

    @State private var wipeLines: [WipeLine] = []
    @State private var currentPoints: [CGPoint] = []

    private let soundManager = SoundManager.shared
    private let hapticManager = HapticManager.shared

    public init() {}

    public var body: some View {
        ZStack {
            // Outside view: Warm Sunset Landscape through window
            LinearGradient(
                colors: [Color(hex: "#FF7E5F"), Color(hex: "#FEB47B"), Color(hex: "#86A8E7"), Color(hex: "#2B5876")],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            // Outside landscape silhouette (mountains and sun)
            VStack {
                Spacer()
                // Distant Sun
                Circle()
                    .fill(Color(hex: "#FFF4E6"))
                    .frame(width: 80, height: 80)
                    .blur(radius: 4)
                    .offset(x: 50, y: 40)

                // Silhouette mountains
                HStack(spacing: -30) {
                    MountainShape()
                        .fill(Color(hex: "#1E1B4B").opacity(0.8))
                        .frame(height: 220)
                    MountainShape()
                        .fill(Color(hex: "#0F172A").opacity(0.9))
                        .frame(height: 260)
                }
            }
            .ignoresSafeArea()

            // Condensation / Fog Overlay
            Canvas { context, size in
                // Base frosted steam
                context.fill(Path(CGRect(origin: .zero, size: size)), with: .color(Color.white.opacity(0.82)))

                // Clear wipes (masking out fog)
                context.blendMode = .clear

                for line in wipeLines {
                    var path = Path()
                    if let first = line.points.first {
                        path.move(to: first)
                        for pt in line.points.dropFirst() {
                            path.addLine(to: pt)
                        }
                    }
                    context.stroke(
                        path,
                        with: .color(.black),
                        style: StrokeStyle(lineWidth: 42, lineCap: .round, lineJoin: .round)
                    )
                }

                if let first = currentPoints.first {
                    var path = Path()
                    path.move(to: first)
                    for pt in currentPoints.dropFirst() {
                        path.addLine(to: pt)
                    }
                    context.stroke(
                        path,
                        with: .color(.black),
                        style: StrokeStyle(lineWidth: 42, lineCap: .round, lineJoin: .round)
                    )
                }
            }
            .compositingGroup()
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        currentPoints.append(value.location)
                        if currentPoints.count % 8 == 0 {
                            soundManager.playSqueegee()
                            hapticManager.vibrateClick()
                        }
                    }
                    .onEnded { _ in
                        if !currentPoints.isEmpty {
                            wipeLines.append(WipeLine(points: currentPoints))
                            currentPoints = []
                        }
                    }
            )

            // Prompt
            VStack {
                Spacer()
                Text("Gạt ngón tay để lau sạch lớp sương mờ trên cửa kính")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Color.black.opacity(0.7))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.white.opacity(0.7))
                    .clipShape(Capsule())
                    .padding(.bottom, 24)
            }
        }
    }

    public func reset() {
        wipeLines.removeAll()
        currentPoints.removeAll()
        hapticManager.vibrateLight()
    }
}

private struct MountainShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}
