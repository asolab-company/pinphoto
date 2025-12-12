import Foundation
import SwiftUI

enum Data {

    static let applink = URL(string: "https://apps.apple.com/app/id6756491367")!
    static let terms = URL(string: "https://docs.google.com/document/d/e/2PACX-1vTsgVOaPI8-v32k9PxP1kNlTnwGHQ-HRg29SmXCodhYDKfjYhV-TvWnTldxaNrUNzrz5qbrpNBgR1Ol/pub")!
    static let policy = URL(string: "https://docs.google.com/document/d/e/2PACX-1vTsgVOaPI8-v32k9PxP1kNlTnwGHQ-HRg29SmXCodhYDKfjYhV-TvWnTldxaNrUNzrz5qbrpNBgR1Ol/pub")!

    static var shareMessage: String {
        """
        Clean your gallery in seconds! 🧹
        \(applink.absoluteString)
        """
    }

    static var shareItems: [Any] { [shareMessage, applink] }
}

enum Device {
    static var isSmall: Bool {
        UIScreen.main.bounds.height < 700
    }

    static var isMedium: Bool {
        UIScreen.main.bounds.height >= 700 && UIScreen.main.bounds.height < 850
    }

    static var isLarge: Bool {
        UIScreen.main.bounds.height >= 850
    }
}

extension Color {
    init(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

        var rgb: UInt64 = 0
        Scanner(string: hexSanitized).scanHexInt64(&rgb)

        let r = Double((rgb >> 16) & 0xFF) / 255.0
        let g = Double((rgb >> 8) & 0xFF) / 255.0
        let b = Double(rgb & 0xFF) / 255.0

        self.init(red: r, green: g, blue: b)
    }
}

struct BtnStyle: ButtonStyle {
    var height: CGFloat = 50
    var width: CGFloat? = nil

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(
                maxWidth: width ?? .infinity,
                maxHeight: height
            )
            .frame(width: width, height: height)
            .background(
                Color(hex: "#E60000")
                    .cornerRadius(5)
            )
            .foregroundColor(.white)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
    }
}
