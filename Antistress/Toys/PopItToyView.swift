import SwiftUI

public struct PopItToyView: View {
    struct BubbleCell: Identifiable {
        let id: Int
        let row: Int
        let col: Int
        var isPopped: Bool = false
    }

    private let rowColors: [String] = [
        "#FF4D4D", // Red
        "#FF9800", // Orange
        "#FFEB3B", // Yellow
        "#4CAF50", // Green
        "#2196F3", // Blue
        "#9C27B0"  // Purple
    ]

    @State private var cells: [BubbleCell] = []
    @State private var isBoardFlipped: Bool = false
    private let soundManager = SoundManager.shared
    private let hapticManager = HapticManager.shared

    public init() {}

    public var body: some View {
        ZStack {
            Color(hex: "#1E293B").ignoresSafeArea()

            VStack(spacing: 24) {
                // Rainbow silicone pad container
                ZStack {
                    RoundedRectangle(cornerRadius: 32)
                        .fill(Color(hex: "#F1F5F9"))
                        .shadow(color: .black.opacity(0.35), radius: 16, x: 0, y: 10)

                    VStack(spacing: 12) {
                        ForEach(0..<6, id: \.self) { row in
                            HStack(spacing: 12) {
                                ForEach(0..<6, id: \.self) { col in
                                    let index = row * 6 + col
                                    if index < cells.count {
                                        popButton(cell: cells[index], color: Color(hex: rowColors[row]))
                                    }
                                }
                            }
                        }
                    }
                    .padding(20)
                }
                .aspectRatio(1.0, contentMode: .fit)
                .padding(.horizontal, 24)
                .rotation3DEffect(.degrees(isBoardFlipped ? 180 : 0), axis: (x: 0, y: 1, z: 0))
                .animation(.spring(response: 0.6, dampingFraction: 0.7), value: isBoardFlipped)

                // Flip board action button
                Button {
                    flipBoard()
                } label: {
                    Label("Lật ngược mặt đồ chơi", systemImage: "arrow.triangle.2.circlepath")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(Color.white.opacity(0.12))
                        .clipShape(Capsule())
                }
            }
        }
        .onAppear {
            setupCells()
        }
    }

    private func popButton(cell: BubbleCell, color: Color) -> some View {
        Button {
            toggleCell(at: cell.id)
        } label: {
            ZStack {
                Circle()
                    .fill(color.opacity(cell.isPopped ? 0.65 : 1.0))
                    .overlay(
                        Circle()
                            .stroke(Color.white.opacity(cell.isPopped ? 0.1 : 0.4), lineWidth: 3)
                    )
                    .shadow(
                        color: cell.isPopped ? Color.black.opacity(0.4) : Color.white.opacity(0.3),
                        radius: cell.isPopped ? 2 : 4,
                        x: cell.isPopped ? 1 : -2,
                        y: cell.isPopped ? 1 : -2
                    )

                Circle()
                    .stroke(Color.black.opacity(cell.isPopped ? 0.35 : 0.08), lineWidth: 4)
                    .scaleEffect(cell.isPopped ? 0.75 : 0.9)

                // Depth highlight
                if !cell.isPopped {
                    Circle()
                        .fill(Color.white.opacity(0.35))
                        .frame(width: 14, height: 14)
                        .offset(x: -6, y: -6)
                }
            }
            .scaleEffect(cell.isPopped ? 0.88 : 1.0)
            .animation(.spring(response: 0.25, dampingFraction: 0.5), value: cell.isPopped)
        }
        .buttonStyle(.plain)
    }

    private func setupCells() {
        var list: [BubbleCell] = []
        for r in 0..<6 {
            for c in 0..<6 {
                list.append(BubbleCell(id: r * 6 + c, row: r, col: c, isPopped: false))
            }
        }
        self.cells = list
    }

    private func toggleCell(at id: Int) {
        guard let index = cells.firstIndex(where: { $0.id == id }) else { return }
        cells[index].isPopped.toggle()
        if cells[index].isPopped {
            soundManager.playPopDeep()
            hapticManager.vibratePop()
        } else {
            soundManager.playPop()
            hapticManager.vibrateLight()
        }
    }

    private func flipBoard() {
        isBoardFlipped.toggle()
        for i in cells.indices {
            cells[i].isPopped.toggle()
        }
        soundManager.playButtonClick()
        hapticManager.vibrateHeavy()
    }

    public func reset() {
        for i in cells.indices {
            cells[i].isPopped = false
        }
        isBoardFlipped = false
        hapticManager.vibrateLight()
    }
}

