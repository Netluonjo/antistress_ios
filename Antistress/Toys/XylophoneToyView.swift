import SwiftUI

public struct XylophoneToyView: View {
    struct Bar: Identifiable {
        let id: Int
        let note: String
        let colorHex: String
        let lengthRatio: CGFloat
    }

    private let bars: [Bar] = [
        Bar(id: 0, note: "C5", colorHex: "#EF4444", lengthRatio: 1.00),
        Bar(id: 1, note: "D5", colorHex: "#F97316", lengthRatio: 0.93),
        Bar(id: 2, note: "E5", colorHex: "#EAB308", lengthRatio: 0.86),
        Bar(id: 3, note: "F5", colorHex: "#22C55E", lengthRatio: 0.80),
        Bar(id: 4, note: "G5", colorHex: "#06B6D4", lengthRatio: 0.74),
        Bar(id: 5, note: "A5", colorHex: "#3B82F6", lengthRatio: 0.68),
        Bar(id: 6, note: "B5", colorHex: "#8B5CF6", lengthRatio: 0.63),
        Bar(id: 7, note: "C6", colorHex: "#EC4899", lengthRatio: 0.58)
    ]

    @State private var activeBarId: Int? = nil
    private let soundManager = SoundManager.shared
    private let hapticManager = HapticManager.shared

    public init() {}

    public var body: some View {
        GeometryReader { geo in
            ZStack {
                // Birch wood frame background
                Color(hex: "#1C1917").ignoresSafeArea()

                VStack(spacing: 14) {
                    ForEach(bars) { bar in
                        barView(bar: bar, maxWidth: geo.size.width - 48)
                    }
                }
                .padding(.vertical, 24)
            }
        }
    }

    private func barView(bar: Bar, maxWidth: CGFloat) -> some View {
        let isHit = activeBarId == bar.id
        let barWidth = maxWidth * bar.lengthRatio

        return Button {
            strikeBar(bar.id)
        } label: {
            ZStack {
                // Shadow
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.black.opacity(0.35))
                    .frame(width: barWidth, height: 46)
                    .offset(y: 4)

                // Colored Tone Bar
                RoundedRectangle(cornerRadius: 12)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(hex: bar.colorHex).opacity(0.9),
                                Color(hex: bar.colorHex),
                                Color(hex: bar.colorHex).opacity(0.8)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: barWidth, height: 46)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.white.opacity(isHit ? 0.7 : 0.25), lineWidth: 2)
                    )

                // Screws on left and right
                HStack {
                    screwHead()
                        .padding(.leading, 18)
                    Spacer()
                    Text(bar.note)
                        .font(.system(size: 15, weight: .black, design: .rounded))
                        .foregroundColor(.white.opacity(0.9))
                    Spacer()
                    screwHead()
                        .padding(.trailing, 18)
                }
                .frame(width: barWidth)
            }
            .scaleEffect(isHit ? 0.97 : 1.0)
            .animation(.spring(response: 0.2, dampingFraction: 0.4), value: isHit)
        }
        .buttonStyle(.plain)
    }

    private func screwHead() -> some View {
        Circle()
            .fill(Color(hex: "#E2E8F0"))
            .frame(width: 8, height: 8)
            .shadow(color: .black.opacity(0.4), radius: 1)
    }

    private func strikeBar(_ id: Int) {
        activeBarId = id
        soundManager.playXylophoneNote(index: id)
        hapticManager.vibrateLight()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            if activeBarId == id {
                activeBarId = nil
            }
        }
    }

    public func reset() {
        activeBarId = nil
        hapticManager.vibrateLight()
    }
}
