import StoreKit
import SwiftUI

struct SettingsView: View {
    @ObservedObject var adManager: AdRemovalManager
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
                            .frame(height: 190)
                            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))

                        SettingsPanel(
                            icon: adManager.isAdFree ? "checkmark.seal.fill" : "xmark.seal.fill",
                            title: adManager.isAdFree ? "広告は非表示です" : "広告を非表示",
                            text: "ニュース一覧を広く使いたい場合は、広告を外せます。",
                            tint: adManager.isAdFree ? .green : .jfRed
                        ) {
                            if !adManager.isAdFree {
                                PurchaseButton(title: adManager.product.map { "広告を非表示 - \($0.displayPrice)" } ?? "広告を非表示") {
                                    Task { await adManager.purchase() }
                                }
                            }
                        }

                        SettingsPanel(icon: "tram.fill", title: "鉄道タブ", text: "鉄道関連の速報を専用タブで確認します。", tint: .jfCyan) {
                            UnlockButton(isUnlocked: adManager.isTrainUnlocked, product: adManager.trainProduct) {
                                Task { await adManager.purchaseTrain() }
                            }
                        }

                        SettingsPanel(icon: "waveform.path.ecg", title: "地震タブ", text: "地震速報と防災メモを専用タブで確認します。", tint: .jfAmber) {
                            UnlockButton(isUnlocked: adManager.isEarthquakeUnlocked, product: adManager.earthquakeProduct) {
                                Task { await adManager.purchaseEarthquake() }
                            }
                        }

                        Button("購入を復元") {
                            Task { await adManager.restore() }
                        }
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundColor(.jfSubtext)
                    }
                    .padding(18)
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

private struct SettingsPanel<Content: View>: View {
    let icon: String
    let title: String
    let text: String
    let tint: Color
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .foregroundColor(tint)
                    .frame(width: 34, height: 34)
                    .background(tint.opacity(0.14))
                    .clipShape(Circle())
                VStack(alignment: .leading, spacing: 3) {
                    Text(title)
                        .font(.system(size: 17, weight: .black, design: .rounded))
                        .foregroundColor(.jfText)
                    Text(text)
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundColor(.jfSubtext)
                }
            }
            content
        }
        .glassCard()
    }
}

private struct PurchaseButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .frame(maxWidth: .infinity)
        }
        .font(.system(size: 15, weight: .black, design: .rounded))
        .foregroundColor(.jfText)
        .padding(.vertical, 13)
        .background(Color.jfRed)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}

private struct UnlockButton: View {
    let isUnlocked: Bool
    let product: Product?
    let action: () -> Void

    var body: some View {
        if isUnlocked {
            Label("解放済み", systemImage: "checkmark.circle.fill")
                .font(.system(size: 14, weight: .black, design: .rounded))
                .foregroundColor(.green)
        } else {
            Button(action: action) {
                Text(product.map { "解放 - \($0.displayPrice)" } ?? "解放")
                    .frame(maxWidth: .infinity)
            }
            .font(.system(size: 15, weight: .black, design: .rounded))
            .foregroundColor(.jfText)
            .padding(.vertical, 13)
            .background(Color.white.opacity(0.12))
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
    }
}
