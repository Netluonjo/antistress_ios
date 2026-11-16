import SwiftUI

public enum ToyCategory: String, CaseIterable, Identifiable {
    case all = "ALL"
    case sensory = "SENSORY"
    case physics = "PHYSICS"
    case calm = "CALM"

    public var id: String { rawValue }

    public var displayName: String {
        switch self {
        case .all:
            return "Tất cả"
        case .sensory:
            return "Giác quan & Bóp nổ"
        case .physics:
            return "Vật lý & Cơ học"
        case .calm:
            return "Đời thực & Thư giãn"
        }
    }
}

public protocol ResettableToy {
    func resetToy()
}

public struct Toy: Identifiable, Equatable {
    public let id: String
    public let title: String
    public let subtitle: String
    public let category: ToyCategory
    public let accentColorHex: String
    public let systemIcon: String

    public static func == (lhs: Toy, rhs: Toy) -> Bool {
        lhs.id == rhs.id
    }

    public var accentColor: Color {
        Color(hex: accentColorHex)
    }
}

extension Color {
    init(hex: String) {
        let cleanHex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: cleanHex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch cleanHex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255.0,
            green: Double(g) / 255.0,
            blue: Double(b) / 255.0,
            opacity: Double(a) / 255.0
        )
    }
}
