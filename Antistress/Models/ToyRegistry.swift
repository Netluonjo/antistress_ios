import SwiftUI

public struct ToyRegistry {
    public static let shared = ToyRegistry()

    public let toys: [Toy] = [
        Toy(
            id: "bubble_wrap",
            title: "Tấm xốp bóng",
            subtitle: "Bóp nổ bong bóng khí xả stress",
            category: .sensory,
            accentColorHex: "#00B4D8",
            systemIcon: "circle.grid.3x3.fill"
        ),
        Toy(
            id: "pop_it",
            title: "Đồ chơi Pop-it",
            subtitle: "Bảng silicon cầu vồng bấm nảy",
            category: .sensory,
            accentColorHex: "#FF4365",
            systemIcon: "circle.hexagongrid.fill"
        ),
        Toy(
            id: "switches",
            title: "Nút bấm & Công tắc",
            subtitle: "Công tắc kim loại, arcade & gạt",
            category: .sensory,
            accentColorHex: "#EAB308",
            systemIcon: "switch.2"
        ),
        Toy(
            id: "slime",
            title: "Chất nhờn Slime",
            subtitle: "Bóng dẻo bóp mềm, kéo giãn",
            category: .sensory,
            accentColorHex: "#22C55E",
            systemIcon: "drop.fill"
        ),
        Toy(
            id: "fidget_spinner",
            title: "Con quay Spinner",
            subtitle: "Con quay bạc đạn xoay tít",
            category: .physics,
            accentColorHex: "#06B6D4",
            systemIcon: "rays"
        ),
        Toy(
            id: "newtons_cradle",
            title: "Nôi của Newton",
            subtitle: "5 viên bi thép truyền động lượng",
            category: .physics,
            accentColorHex: "#94A3B8",
            systemIcon: "circle.circle"
        ),
        Toy(
            id: "pen_click",
            title: "Bút bấm tách tách",
            subtitle: "Bút bi lò xo & vẽ nguệch ngoạc",
            category: .physics,
            accentColorHex: "#2563EB",
            systemIcon: "pencil.tip"
        ),
        Toy(
            id: "xylophone",
            title: "Đàn phiến gỗ",
            subtitle: "8 phím âm hưởng C5 - C6 thanh thoát",
            category: .physics,
            accentColorHex: "#F97316",
            systemIcon: "pianokeys"
        ),
        Toy(
            id: "bamboo_chimes",
            title: "Chuông gió tre",
            subtitle: "Ống tre đong đưa gõ lách cách",
            category: .physics,
            accentColorHex: "#D4A373",
            systemIcon: "wind"
        ),
        Toy(
            id: "lotus_pond",
            title: "Ao sen thư giãn",
            subtitle: "Vờn sóng nước & ngắm cá Koi bơi",
            category: .calm,
            accentColorHex: "#0284C7",
            systemIcon: "leaf.fill"
        ),
        Toy(
            id: "chalkboard",
            title: "Bảng phấn",
            subtitle: "Vẽ phấn màu trên bảng xanh",
            category: .calm,
            accentColorHex: "#15803D",
            systemIcon: "square.and.pencil"
        ),
        Toy(
            id: "window_wipe",
            title: "Lau kính sương mù",
            subtitle: "Gạt sương mờ ngắm hoàng hôn",
            category: .calm,
            accentColorHex: "#6366F1",
            systemIcon: "cloud.fog.fill"
        ),
        Toy(
            id: "coin_polish",
            title: "Làm sạch đồng xu",
            subtitle: "Đánh bóng đồng tiền vàng cổ xưa",
            category: .calm,
            accentColorHex: "#EAB308",
            systemIcon: "dollarsign.circle.fill"
        ),
        Toy(
            id: "wood_chop",
            title: "Chẻ củi mộc",
            subtitle: "Bổ củi gỗ giòn tan với rìu",
            category: .calm,
            accentColorHex: "#B45309",
            systemIcon: "hammer.fill"
        ),
        Toy(
            id: "zen_garden",
            title: "Vườn cát Zen",
            subtitle: "Cào cát trắng & sỏi sông bình yên",
            category: .calm,
            accentColorHex: "#A8A29E",
            systemIcon: "waveform.path"
        )
    ]

    @ViewBuilder
    public func makeToyView(for id: String) -> some View {
        switch id {
        case "bubble_wrap":
            BubbleWrapToyView()
        case "pop_it":
            PopItToyView()
        case "switches":
            SwitchesToyView()
        case "slime":
            SlimeToyView()
        case "fidget_spinner":
            FidgetSpinnerToyView()
        case "newtons_cradle":
            NewtonsCradleToyView()
        case "pen_click":
            RetractablePenToyView()
        case "xylophone":
            XylophoneToyView()
        case "bamboo_chimes":
            BambooChimesToyView()
        case "lotus_pond":
            LotusPondToyView()
        case "chalkboard":
            ChalkboardToyView()
        case "window_wipe":
            WindowWipeToyView()
        case "coin_polish":
            CoinPolishToyView()
        case "wood_chop":
            WoodChopToyView()
        case "zen_garden":
            ZenGardenToyView()
        default:
            BubbleWrapToyView()
        }
    }
}
