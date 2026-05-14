import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                JFBackground()

                ScrollView {
                    VStack(spacing: 16) {
                        Image("jiken-saved")
                            .resizable()
                            .scaledToFill()
                            .frame(height: 180)
                            .clipped()
                            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))

                        SettingsPanel(
                            icon: "megaphone.fill",
                            title: "無料で利用できます",
                            text: "事件速報は広告で運営しています。アプリ内課金はありません。",
                            tint: .jfCyan
                        )

                        SettingsPanel(
                            icon: "shield.checkered",
                            title: "速報の見方",
                            text: "気になる速報を開くと、要点・確認先・安全メモを整理して確認できます。",
                            tint: .jfRed
                        )

                        SettingsPanel(
                            icon: "location.fill",
                            title: "近くの速報",
                            text: "位置情報を許可すると、近い可能性がある速報を優先して見られます。",
                            tint: .jfAmber
                        )
                    }
                    .padding(18)
                    .frame(maxWidth: 430)
                    .frame(maxWidth: .infinity)
                }
            }
            .navigationTitle("設定")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("閉じる") { dismiss() }
                        .foregroundColor(.jfRed)
                }
            }
        }
    }
}

private struct SettingsPanel: View {
    let icon: String
    let title: String
    let text: String
    let tint: Color

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(tint)
                .frame(width: 34, height: 34)
                .background(tint.opacity(0.14))
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.system(size: 17, weight: .black, design: .rounded))
                    .foregroundColor(.jfText)
                Text(text)
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(.jfSubtext)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .glassCard(padding: 14)
    }
}
