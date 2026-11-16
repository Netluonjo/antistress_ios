import SwiftUI

public struct ToyCardView: View {
    public let toy: Toy

    public init(toy: Toy) {
        self.toy = toy
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Icon Badge
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(
                            colors: [toy.accentColor.opacity(0.85), toy.accentColor],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 52, height: 52)
                    .shadow(color: toy.accentColor.opacity(0.4), radius: 8, x: 0, y: 4)

                Image(systemName: toy.systemIcon)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(toy.title)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .lineLimit(1)

                Text(toy.subtitle)
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(Color(hex: "#94A3B8"))
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 0)
        }
        .padding(16)
        .frame(maxWidth: .infinity, minHeight: 140, alignment: .topLeading)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(hex: "#1E293B"))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(toy.accentColor.opacity(0.3), lineWidth: 1.5)
                )
                .shadow(color: Color.black.opacity(0.25), radius: 8, x: 0, y: 4)
        )
    }
}

