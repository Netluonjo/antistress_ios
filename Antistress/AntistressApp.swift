import SwiftUI

@main
struct AntistressApp: App {
    init() {
        // Pre-warm haptic generators and sound synthesis
        HapticManager.shared.prepare()
        _ = SoundManager.shared
    }

    var body: some Scene {
        WindowGroup {
            MainShelfView()
                .preferredColorScheme(.dark)
        }
    }
}

