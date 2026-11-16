import SwiftUI

public struct RetractablePenToyView: View {
    @State private var isPenClicked: Bool = true
    @State private var doodleLines: [[CGPoint]] = []
    @State private var currentLine: [CGPoint] = []

    private let soundManager = SoundManager.shared
    private let hapticManager = HapticManager.shared

    public init() {}

    public var body: some View {
        ZStack {
            // Desk background
            Color(hex: "#1E293B").ignoresSafeArea()

            VStack(spacing: 20) {
                // Interactive Clicker Pen (Horizontal display)
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(hex: "#0F172A").opacity(0.6))
                        .frame(height: 120)

                    HStack(spacing: 0) {
                        // Pen Clicker Button
                        Button {
                            togglePenClick()
                        } label: {
                            ZStack {
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(
                                        LinearGradient(
                                            colors: [Color(hex: "#CBD5E1"), Color(hex: "#94A3B8")],
                                            startPoint: .top,
                                            endPoint: .bottom
                                        )
                                    )
                                    .frame(width: isPenClicked ? 14 : 26, height: 18)
                                    .shadow(color: .black.opacity(0.3), radius: 2)
                                    .animation(.spring(response: 0.15, dampingFraction: 0.5), value: isPenClicked)
                            }
                        }
                        .buttonStyle(.plain)

                        // Pen Barrel Body
                        ZStack(alignment: .leading) {
                            Capsule()
                                .fill(
                                    LinearGradient(
                                        colors: [Color(hex: "#2563EB"), Color(hex: "#1D4ED8"), Color(hex: "#1E40AF")],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                .frame(width: 200, height: 26)
                                .shadow(color: .black.opacity(0.4), radius: 6)

                            // Metal Clip
                            Capsule()
                                .fill(Color(hex: "#E2E8F0"))
                                .frame(width: 60, height: 5)
                                .offset(x: 10, y: -16)

                            // Grip grooves
                            HStack(spacing: 4) {
                                ForEach(0..<5) { _ in
                                    Rectangle()
                                        .fill(Color.black.opacity(0.2))
                                        .frame(width: 2, height: 24)
                                }
                            }
                            .offset(x: 140)
                        }

                        // Pen Cone & Tip
                        HStack(spacing: 0) {
                            // Metal cone
                            Triangle()
                                .fill(
                                    LinearGradient(
                                        colors: [Color(hex: "#E2E8F0"), Color(hex: "#94A3B8")],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                .frame(width: 22, height: 24)
                                .rotationEffect(.degrees(90))

                            // Ballpoint tip
                            if isPenClicked {
                                Capsule()
                                    .fill(Color(hex: "#475569"))
                                    .frame(width: 10, height: 4)
                                    .transition(.scale)
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)

                // Doodling Notepad
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(hex: "#FFFBEB")) // Cream notebook paper
                        .shadow(color: .black.opacity(0.4), radius: 12)

                    // Ruled paper lines
                    VStack(spacing: 24) {
                        ForEach(0..<14) { _ in
                            Divider().background(Color(hex: "#E2E8F0"))
                        }
                    }
                    .padding(.horizontal, 16)

                    // Doodle Canvas
                    Canvas { context, size in
                        for line in doodleLines {
                            var path = Path()
                            if let first = line.first {
                                path.move(to: first)
                                for pt in line.dropFirst() {
                                    path.addLine(to: pt)
                                }
                            }
                            context.stroke(path, with: .color(Color(hex: "#1D4ED8")), lineWidth: 2.5)
                        }

                        if let first = currentLine.first {
                            var path = Path()
                            path.move(to: first)
                            for pt in currentLine.dropFirst() {
                                path.addLine(to: pt)
                            }
                            context.stroke(path, with: .color(Color(hex: "#1D4ED8")), lineWidth: 2.5)
                        }
                    }
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { value in
                                guard isPenClicked else { return }
                                currentLine.append(value.location)
                                if currentLine.count % 8 == 0 {
                                    hapticManager.vibrateLight()
                                }
                            }
                            .onEnded { _ in
                                guard isPenClicked else { return }
                                if !currentLine.isEmpty {
                                    doodleLines.append(currentLine)
                                    currentLine = []
                                }
                            }
                    )

                    if !isPenClicked {
                        VStack {
                            Text("Bấm vào đuôi bút bi phía trên để mở ngòi bút")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(Color.black.opacity(0.5))
                                .padding()
                                .background(Color.white.opacity(0.85))
                                .cornerRadius(8)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
        }
    }

    private func togglePenClick() {
        isPenClicked.toggle()
        soundManager.playPenClick(isRelease: !isPenClicked)
        hapticManager.vibrateClick()
    }

    public func reset() {
        doodleLines.removeAll()
        currentLine.removeAll()
        isPenClicked = true
        hapticManager.vibrateLight()
    }
}

private struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

