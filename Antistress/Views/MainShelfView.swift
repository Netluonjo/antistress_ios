import SwiftUI

public struct MainShelfView: View {
    @State private var selectedCategory: ToyCategory = .all
    @State private var selectedToy: Toy? = nil

    @ObservedObject private var soundManager = SoundManager.shared
    @ObservedObject private var hapticManager = HapticManager.shared

    private let columns = [
        GridItem(.flexible(), spacing: 14),
        GridItem(.flexible(), spacing: 14)
    ]

    public init() {}

    private var filteredToys: [Toy] {
        if selectedCategory == .all {
            return ToyRegistry.shared.toys
        }
        return ToyRegistry.shared.toys.filter { $0.category == selectedCategory }
    }

    public var body: some View {
        ZStack {
            // Dark luxury background
            Color(hex: "#0F172A").ignoresSafeArea()

            VStack(spacing: 0) {
                // Top Header Bar
                HStack(alignment: .center) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Antistress")
                            .font(.system(size: 28, weight: .black, design: .rounded))
                            .foregroundColor(.white)
                        Text("15 Đồ chơi thư giãn & xả stress")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(Color(hex: "#94A3B8"))
                    }

                    Spacer()

                    // Quick Master Controls (Haptic & Sound)
                    HStack(spacing: 10) {
                        Button {
                            hapticManager.isHapticEnabled.toggle()
                            if hapticManager.isHapticEnabled {
                                hapticManager.vibrateLight()
                            }
                        } label: {
                            Image(systemName: hapticManager.isHapticEnabled ? "iphone.radiowaves.left.and.right" : "iphone.slash")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(hapticManager.isHapticEnabled ? Color(hex: "#38BDF8") : .gray)
                                .frame(width: 40, height: 40)
                                .background(Color.white.opacity(0.08))
                                .clipShape(Circle())
                        }

                        Button {
                            soundManager.isSoundEnabled.toggle()
                            if soundManager.isSoundEnabled {
                                soundManager.playButtonClick()
                            }
                        } label: {
                            Image(systemName: soundManager.isSoundEnabled ? "speaker.wave.2.fill" : "speaker.slash.fill")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(soundManager.isSoundEnabled ? Color(hex: "#38BDF8") : .gray)
                                .frame(width: 40, height: 40)
                                .background(Color.white.opacity(0.08))
                                .clipShape(Circle())
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 12)

                // Category Chips ScrollView
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(ToyCategory.allCases) { category in
                            categoryChip(category: category)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 8)
                }

                // Grid of Toy Cards
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 14) {
                        ForEach(filteredToys) { toy in
                            Button {
                                hapticManager.vibrateClick()
                                soundManager.playButtonClick()
                                selectedToy = toy
                            } label: {
                                ToyCardView(toy: toy)
                            }
                            .buttonStyle(CardPressButtonStyle())
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                    .padding(.bottom, 30)
                }
            }
        }
        .fullScreenCover(item: $selectedToy) { toy in
            ToyDetailContainerView(toy: toy)
        }
    }

    private func categoryChip(category: ToyCategory) -> some View {
        let isSelected = selectedCategory == category
        return Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                selectedCategory = category
            }
            hapticManager.vibrateClick()
        } label: {
            Text(category.displayName)
                .font(.system(size: 13, weight: isSelected ? .bold : .medium))
                .foregroundColor(isSelected ? .white : Color(hex: "#94A3B8"))
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(isSelected ? Color(hex: "#2563EB") : Color.white.opacity(0.08))
                )
        }
        .buttonStyle(.plain)
    }
}

private struct CardPressButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.easeInOut(duration: 0.12), value: configuration.isPressed)
    }
}

