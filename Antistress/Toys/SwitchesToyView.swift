import SwiftUI

public struct SwitchesToyView: View {
    @State private var pwrToggle: Bool = true
    @State private var auxToggle: Bool = false
    @State private var rockerOn: Bool = true
    @State private var arcadePressed: Bool = false
    @State private var sliderValue: Double = 0.65

    private let soundManager = SoundManager.shared
    private let hapticManager = HapticManager.shared

    public init() {}

    public var body: some View {
        ZStack {
            // Dark brushed industrial plate
            Color(hex: "#18181B").ignoresSafeArea()

            VStack(spacing: 32) {
                // Top row: Dual Industrial Lever Toggles
                HStack(spacing: 48) {
                    industrialToggle(label: "PWR", isOn: $pwrToggle, ledColor: Color.green)
                    industrialToggle(label: "AUX", isOn: $auxToggle, ledColor: Color.orange)
                }
                .padding(.top, 24)

                // Middle: Big Arcade Button
                VStack(spacing: 12) {
                    arcadeButton()
                    Text("PUNCH BUTTON")
                        .font(.system(size: 13, weight: .bold, design: .monospaced))
                        .foregroundColor(Color.gray)
                }

                // Bottom row: Rocker switch & Slider fader
                HStack(spacing: 40) {
                    rockerSwitch()

                    // Vertical or horizontal fader
                    VStack(alignment: .leading, spacing: 8) {
                        Text("GAIN : \(Int(sliderValue * 100))%")
                            .font(.system(size: 13, weight: .bold, design: .monospaced))
                            .foregroundColor(.gray)

                        Slider(value: $sliderValue, in: 0...1) { editing in
                            if editing {
                                hapticManager.vibrateLight()
                            }
                        }
                        .accentColor(Color(hex: "#38BDF8"))
                        .onChange(of: sliderValue) { _ in
                            hapticManager.vibrateClick()
                        }
                    }
                    .frame(maxWidth: 160)
                }
                .padding(.horizontal, 24)
            }
            .padding(24)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color(hex: "#27272A"))
                    .overlay(
                        RoundedRectangle(cornerRadius: 24)
                            .stroke(Color(hex: "#3F3F46"), lineWidth: 2)
                    )
                    .shadow(color: .black.opacity(0.5), radius: 20)
            )
            .padding(20)
        }
    }

    private func industrialToggle(label: String, isOn: Binding<Bool>, ledColor: Color) -> some View {
        VStack(spacing: 12) {
            // LED Indicator
            Circle()
                .fill(isOn.wrappedValue ? ledColor : Color.black.opacity(0.6))
                .frame(width: 12, height: 12)
                .shadow(color: isOn.wrappedValue ? ledColor : .clear, radius: 6)

            Button {
                isOn.wrappedValue.toggle()
                soundManager.playSwitch(isOn: isOn.wrappedValue)
                hapticManager.vibrateRigid()
            } label: {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(hex: "#3F3F46"))
                        .frame(width: 48, height: 72)

                    // Chrome bat lever
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [Color(hex: "#F1F5F9"), Color(hex: "#94A3B8"), Color(hex: "#64748B")],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: 14, height: 38)
                        .offset(y: isOn.wrappedValue ? -14 : 14)
                        .shadow(color: .black.opacity(0.4), radius: 4)
                        .animation(.spring(response: 0.2, dampingFraction: 0.5), value: isOn.wrappedValue)
                }
            }
            .buttonStyle(.plain)

            Text(label)
                .font(.system(size: 13, weight: .black, design: .monospaced))
                .foregroundColor(.white.opacity(0.8))
        }
    }

    private func arcadeButton() -> some View {
        Button {
            soundManager.playButtonClick()
            hapticManager.vibrateHeavy()
        } label: {
            ZStack {
                // Bezel
                Circle()
                    .fill(Color(hex: "#18181B"))
                    .frame(width: 140, height: 140)
                    .shadow(color: .black.opacity(0.6), radius: 10, y: 6)

                Circle()
                    .stroke(Color(hex: "#52525B"), lineWidth: 4)
                    .frame(width: 136, height: 136)

                // Red button dome
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color(hex: "#EF4444"), Color(hex: "#B91C1C")],
                            center: .center,
                            startRadius: 5,
                            endRadius: 55
                        )
                    )
                    .frame(width: arcadePressed ? 104 : 110, height: arcadePressed ? 104 : 110)
                    .overlay(
                        Circle()
                            .fill(Color.white.opacity(arcadePressed ? 0.05 : 0.25))
                            .frame(width: 60, height: 30)
                            .offset(y: -24)
                    )
                    .shadow(color: .black.opacity(0.4), radius: arcadePressed ? 2 : 6, y: arcadePressed ? 1 : 4)
            }
        }
        .buttonStyle(ArcadePressButtonStyle(isPressedBinding: $arcadePressed))
    }

    private func rockerSwitch() -> some View {
        VStack(spacing: 8) {
            Button {
                rockerOn.toggle()
                soundManager.playSwitch(isOn: rockerOn)
                hapticManager.vibratePop()
            } label: {
                ZStack {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.black)
                        .frame(width: 50, height: 80)

                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color(hex: rockerOn ? "#22C55E" : "#3F3F46"))
                        .frame(width: 44, height: 38)
                        .offset(y: rockerOn ? -18 : 18)
                        .overlay(
                            Text(rockerOn ? "I" : "O")
                                .font(.system(size: 16, weight: .black, design: .monospaced))
                                .foregroundColor(.white)
                        )
                        .animation(.easeInOut(duration: 0.12), value: rockerOn)
                }
            }
            .buttonStyle(.plain)

            Text("MODE")
                .font(.system(size: 11, weight: .bold, design: .monospaced))
                .foregroundColor(.gray)
        }
    }

    public func reset() {
        pwrToggle = true
        auxToggle = false
        rockerOn = true
        sliderValue = 0.5
        hapticManager.vibrateLight()
    }
}

struct ArcadePressButtonStyle: ButtonStyle {
    @Binding var isPressedBinding: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.94 : 1.0)
            .onChange(of: configuration.isPressed) { pressed in
                isPressedBinding = pressed
            }
    }
}

