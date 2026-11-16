import SwiftUI

public struct ChalkboardToyView: View {
    private struct ChalkStroke: Identifiable {
        let id: UUID = UUID()
        var points: [CGPoint]
        let color: Color
        let width: CGFloat
    }

    private let chalkColors: [(name: String, color: Color)] = [
        ("Trắng", Color.white),
        ("Vàng", Color(hex: "#FEF08A")),
        ("Xanh", Color(hex: "#86EFAC")),
        ("Hồng", Color(hex: "#F472B6"))
    ]

    @State private var strokes: [ChalkStroke] = []
    @State private var currentPoints: [CGPoint] = []
    @State private var selectedColorIndex: Int = 0
    @State private var isEraserActive: Bool = false

    private let soundManager = SoundManager.shared
    private let hapticManager = HapticManager.shared

    public init() {}

    public var body: some View {
        ZStack {
            // Wood Frame
            Color(hex: "#78350F").ignoresSafeArea()

            VStack(spacing: 16) {
                // Chalkboard surface
                ZStack {
                    // Deep school chalkboard green
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(hex: "#14532D"))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color(hex: "#451A03"), lineWidth: 10)
                        )
                        .shadow(color: .black.opacity(0.4), radius: 10)

                    // Strokes Canvas
                    Canvas { context, _ in
                        for stroke in strokes {
                            var path = Path()
                            if let first = stroke.points.first {
                                path.move(to: first)
                                for pt in stroke.points.dropFirst() {
                                    path.addLine(to: pt)
                                }
                            }
                            context.stroke(
                                path,
                                with: .color(stroke.color),
                                style: StrokeStyle(lineWidth: stroke.width, lineCap: .round, lineJoin: .round)
                            )
                        }

                        if let first = currentPoints.first {
                            var path = Path()
                            path.move(to: first)
                            for pt in currentPoints.dropFirst() {
                                path.addLine(to: pt)
                            }
                            let activeColor = isEraserActive ? Color(hex: "#14532D") : chalkColors[selectedColorIndex].color
                            context.stroke(
                                path,
                                with: .color(activeColor),
                                style: StrokeStyle(lineWidth: isEraserActive ? 28 : 4, lineCap: .round, lineJoin: .round)
                            )
                        }
                    }
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { value in
                                currentPoints.append(value.location)
                                if currentPoints.count % 6 == 0 {
                                    soundManager.playChalk()
                                    hapticManager.vibrateClick()
                                }
                            }
                            .onEnded { _ in
                                if !currentPoints.isEmpty {
                                    let color = isEraserActive ? Color(hex: "#14532D") : chalkColors[selectedColorIndex].color
                                    let width: CGFloat = isEraserActive ? 28 : 4
                                    strokes.append(ChalkStroke(points: currentPoints, color: color, width: width))
                                    currentPoints = []
                                }
                            }
                    )
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)

                // Bottom Chalk Tray & Tools
                HStack(spacing: 16) {
                    // Chalk pieces
                    ForEach(0..<chalkColors.count, id: \.self) { idx in
                        Button {
                            selectedColorIndex = idx
                            isEraserActive = false
                            soundManager.playButtonClick()
                            hapticManager.vibrateLight()
                        } label: {
                            Capsule()
                                .fill(chalkColors[idx].color)
                                .frame(width: 44, height: 16)
                                .overlay(
                                    Capsule()
                                        .stroke(Color.white, lineWidth: (!isEraserActive && selectedColorIndex == idx) ? 2.5 : 0)
                                )
                                .shadow(color: .black.opacity(0.3), radius: 3)
                        }
                    }

                    Spacer()

                    // Eraser Tool
                    Button {
                        isEraserActive.toggle()
                        soundManager.playButtonClick()
                        hapticManager.vibrateLight()
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "eraser.fill")
                            Text("Khăn lau")
                        }
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(isEraserActive ? Color(hex: "#B45309") : Color.black.opacity(0.4))
                        .cornerRadius(8)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 20)
            }
        }
    }

    public func reset() {
        strokes.removeAll()
        currentPoints.removeAll()
        isEraserActive = false
        hapticManager.vibrateLight()
    }
}

