import SwiftUI

public struct ToyDetailContainerView: View {
    public let toy: Toy
    @Environment(\.dismiss) private var dismiss

    @ObservedObject private var soundManager = SoundManager.shared
    @ObservedObject private var hapticManager = HapticManager.shared
    @State private var resetKey: UUID = UUID()

    public init(toy: Toy) {
        self.toy = toy
    }

    public var body: some View {
        ZStack {
            Color(hex: "#0F172A").ignoresSafeArea()

            VStack(spacing: 0) {
                // Top Custom Navigation Bar
                HStack(spacing: 12) {
                    // Back Button
                    Button {
                        hapticManager.vibrateClick()
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 40, height: 40)
                            .background(Color.white.opacity(0.12))
                            .clipShape(Circle())
                    }

                    // Toy Title
                    VStack(alignment: .leading, spacing: 2) {
                        Text(toy.title)
                            .font(.system(size: 17, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                        Text(toy.category.displayName)
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(toy.accentColor)
                    }

                    Spacer()

                    // Haptic Toggle Button
                    Button {
                        hapticManager.isHapticEnabled.toggle()
                        if hapticManager.isHapticEnabled {
                            hapticManager.vibrateLight()
                        }
                    } label: {
                        Image(systemName: hapticManager.isHapticEnabled ? "iphone.radiowaves.left.and.right" : "iphone.slash")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(hapticManager.isHapticEnabled ? toy.accentColor : .gray)
                            .frame(width: 38, height: 38)
                            .background(Color.white.opacity(0.1))
                            .clipShape(Circle())
                    }

                    // Sound Toggle Button
                    Button {
                        soundManager.isSoundEnabled.toggle()
                        if soundManager.isSoundEnabled {
                            soundManager.playButtonClick()
                        }
                    } label: {
                        Image(systemName: soundManager.isSoundEnabled ? "speaker.wave.2.fill" : "speaker.slash.fill")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(soundManager.isSoundEnabled ? toy.accentColor : .gray)
                            .frame(width: 38, height: 38)
                            .background(Color.white.opacity(0.1))
                            .clipShape(Circle())
                    }

                    // Reset Toy Button
                    Button {
                        resetKey = UUID()
                        soundManager.playButtonClick()
                        hapticManager.vibrateLight()
                    } label: {
                        Image(systemName: "arrow.counterclockwise")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 38, height: 38)
                            .background(Color.white.opacity(0.1))
                            .clipShape(Circle())
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 10)
                .padding(.bottom, 12)
                .background(Color(hex: "#0F172A").opacity(0.95))

                // The Toy interactive body (recreated on resetKey change)
                ToyRegistry.shared.makeToyView(for: toy.id)
                    .id(resetKey)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .navigationBarHidden(true)
    }
}

