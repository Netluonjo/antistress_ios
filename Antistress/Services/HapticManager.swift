import UIKit
import Combine

public final class HapticManager: ObservableObject {
    public static let shared = HapticManager()

    private let keyHapticEnabled = "antistress_haptic_enabled"

    @Published public var isHapticEnabled: Bool {
        didSet {
            UserDefaults.standard.set(isHapticEnabled, forKey: keyHapticEnabled)
        }
    }

    private let lightGenerator = UIImpactFeedbackGenerator(style: .light)
    private let mediumGenerator = UIImpactFeedbackGenerator(style: .medium)
    private let heavyGenerator = UIImpactFeedbackGenerator(style: .heavy)
    private let softGenerator = UIImpactFeedbackGenerator(style: .soft)
    private let rigidGenerator = UIImpactFeedbackGenerator(style: .rigid)
    private let selectionGenerator = UISelectionFeedbackGenerator()
    private let notificationGenerator = UINotificationFeedbackGenerator()

    private init() {
        if UserDefaults.standard.object(forKey: keyHapticEnabled) != nil {
            self.isHapticEnabled = UserDefaults.standard.bool(forKey: keyHapticEnabled)
        } else {
            self.isHapticEnabled = true
        }

        prepare()
    }

    public func prepare() {
        lightGenerator.prepare()
        mediumGenerator.prepare()
        softGenerator.prepare()
        rigidGenerator.prepare()
        selectionGenerator.prepare()
    }

    public func vibrateClick() {
        guard isHapticEnabled else { return }
        selectionGenerator.selectionChanged()
    }

    public func vibrateLight() {
        guard isHapticEnabled else { return }
        lightGenerator.impactOccurred(intensity: 0.7)
    }

    public func vibratePop() {
        guard isHapticEnabled else { return }
        mediumGenerator.impactOccurred(intensity: 0.85)
    }

    public func vibrateHeavy() {
        guard isHapticEnabled else { return }
        heavyGenerator.impactOccurred()
    }

    public func vibrateSoft() {
        guard isHapticEnabled else { return }
        softGenerator.impactOccurred(intensity: 0.6)
    }

    public func vibrateRigid() {
        guard isHapticEnabled else { return }
        rigidGenerator.impactOccurred(intensity: 0.9)
    }

    public func vibrateBallImpact(velocityRatio: Float) {
        guard isHapticEnabled else { return }
        let clamped = max(0.2, min(1.0, CGFloat(velocityRatio)))
        if clamped > 0.65 {
            rigidGenerator.impactOccurred(intensity: clamped)
        } else {
            lightGenerator.impactOccurred(intensity: clamped)
        }
    }

    public func vibrateSuccess() {
        guard isHapticEnabled else { return }
        notificationGenerator.notificationOccurred(.success)
    }
}
