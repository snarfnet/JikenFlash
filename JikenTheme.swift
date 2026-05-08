import SwiftUI

extension Color {
    static let jfBlack = Color(hex: "#070A10")
    static let jfPanel = Color(hex: "#101724")
    static let jfPanelSoft = Color(hex: "#172033")
    static let jfText = Color(hex: "#F8FAFC")
    static let jfSubtext = Color(hex: "#94A3B8")
    static let jfRed = Color(hex: "#EF233C")
    static let jfCyan = Color(hex: "#22D3EE")
    static let jfAmber = Color(hex: "#F59E0B")

    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 255, 255, 255)
        }
        self.init(.sRGB, red: Double(r) / 255, green: Double(g) / 255, blue: Double(b) / 255, opacity: Double(a) / 255)
    }
}

struct JFBackground: View {
    var body: some View {
        ZStack {
            LinearGradient(colors: [.jfBlack, Color(hex: "#0B1220"), .jfBlack], startPoint: .topLeading, endPoint: .bottomTrailing)
            Circle()
                .fill(Color.jfRed.opacity(0.18))
                .frame(width: 340, height: 340)
                .blur(radius: 90)
                .offset(x: -150, y: -260)
            Circle()
                .fill(Color.jfCyan.opacity(0.13))
                .frame(width: 360, height: 360)
                .blur(radius: 100)
                .offset(x: 180, y: 280)
        }
        .ignoresSafeArea()
    }
}

struct GlassCard: ViewModifier {
    var padding: CGFloat = 16

    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(Color.jfPanel.opacity(0.88))
            .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .stroke(Color.white.opacity(0.08), lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.28), radius: 20, x: 0, y: 12)
    }
}

extension View {
    func glassCard(padding: CGFloat = 16) -> some View {
        modifier(GlassCard(padding: padding))
    }
}
