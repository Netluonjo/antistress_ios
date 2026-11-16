import SwiftUI

public struct WoodChopToyView: View {
    @State private var isChopped: Bool = false
    @State private var logOffsetLeft: CGFloat = 0
    @State private var logOffsetRight: CGFloat = 0
    @State private var logRotationLeft: Double = 0
    @State private var logRotationRight: Double = 0
    @State private var axeOffsetY: CGFloat = -140
    @State private var axeRotation: Double = -25

    private let soundManager = SoundManager.shared
    private let hapticManager = HapticManager.shared

    public init() {}

    public var body: some View {
        ZStack {
            // Nordic Pine Forest background
            Color(hex: "#14251B").ignoresSafeArea()

            VStack {
                Spacer()

                ZStack {
                    // Chopping Stump Block
                    StumpView()
                        .offset(y: 80)

                    // The Wood Log (Split into two halves)
                    HStack(spacing: 0) {
                        // Left Half
                        LogHalfView(isLeft: true)
                            .offset(x: logOffsetLeft, y: isChopped ? 40 : 0)
                            .rotationEffect(.degrees(logRotationLeft))

                        // Right Half
                        LogHalfView(isLeft: false)
                            .offset(x: logOffsetRight, y: isChopped ? 40 : 0)
                            .rotationEffect(.degrees(logRotationRight))
                    }
                    .offset(y: -40)

                    // Lumberjack Axe
                    AxeView()
                        .offset(x: 10, y: axeOffsetY)
                        .rotationEffect(.degrees(axeRotation))
                }

                Spacer()

                Text("Chạm vào màn hình để vung rìu bổ củi")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white.opacity(0.6))
                    .padding(.bottom, 24)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            chopWood()
        }
    }

    private func chopWood() {
        guard !isChopped else { return }

        // Axe swing down
        withAnimation(.easeIn(duration: 0.12)) {
            axeOffsetY = -45
            axeRotation = 0
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
            isChopped = true
            soundManager.playWoodChop()
            hapticManager.vibrateHeavy()

            // Halves burst apart
            withAnimation(.easeOut(duration: 0.35)) {
                logOffsetLeft = -90
                logOffsetRight = 90
                logRotationLeft = -35
                logRotationRight = 35
                axeOffsetY = -30
            }

            // Spawn next fresh log after 0.8s
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    isChopped = false
                    logOffsetLeft = 0
                    logOffsetRight = 0
                    logRotationLeft = 0
                    logRotationRight = 0
                    axeOffsetY = -140
                    axeRotation = -25
                }
                hapticManager.vibrateLight()
            }
        }
    }

    public func reset() {
        isChopped = false
        logOffsetLeft = 0
        logOffsetRight = 0
        logRotationLeft = 0
        logRotationRight = 0
        axeOffsetY = -140
        axeRotation = -25
        hapticManager.vibrateLight()
    }
}

private struct StumpView: View {
    var body: some View {
        ZStack {
            // Stump body
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    LinearGradient(
                        colors: [Color(hex: "#78350F"), Color(hex: "#451A03")],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 220, height: 130)

            // Stump top surface rings
            VStack {
                Ellipse()
                    .fill(Color(hex: "#D97706"))
                    .frame(width: 220, height: 50)
                    .overlay(
                        Ellipse()
                            .stroke(Color(hex: "#92400E"), lineWidth: 3)
                            .frame(width: 170, height: 35)
                    )
                Spacer()
            }
            .frame(height: 130)
        }
    }
}

private struct LogHalfView: View {
    let isLeft: Bool

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(
                    LinearGradient(
                        colors: [Color(hex: "#FDE68A"), Color(hex: "#D97706")],
                        startPoint: isLeft ? .trailing : .leading,
                        endPoint: isLeft ? .leading : .trailing
                    )
                )
                .frame(width: 50, height: 130)
                .overlay(
                    // Outer bark strip
                    HStack {
                        if isLeft {
                            Rectangle().fill(Color(hex: "#78350F")).frame(width: 8)
                            Spacer()
                        } else {
                            Spacer()
                            Rectangle().fill(Color(hex: "#78350F")).frame(width: 8)
                        }
                    }
                )
        }
    }
}

private struct AxeView: View {
    var body: some View {
        ZStack(alignment: .bottom) {
            // Ash wood handle
            Capsule()
                .fill(Color(hex: "#FBBF24"))
                .frame(width: 12, height: 160)

            // Steel blade head
            HStack(spacing: 0) {
                Rectangle()
                    .fill(Color(hex: "#334155"))
                    .frame(width: 22, height: 44)
                TriangleAxe()
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: "#E2E8F0"), Color(hex: "#94A3B8")],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: 34, height: 50)
            }
            .offset(x: 16, y: -90)
        }
    }
}

private struct TriangleAxe: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.minY + 4))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY - 4))
        path.closeSubpath()
        return path
    }
}
