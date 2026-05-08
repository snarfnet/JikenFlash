import SwiftUI

struct NewsCardView: View {
    let item: NewsItem
    var distanceKm: Double?
    let isSaved: Bool
    let onSave: () -> Void
    let onOpen: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
                HStack(alignment: .top) {
                    HStack(spacing: 7) {
                        Image(systemName: item.category.icon)
                        Text(item.category.label)
                    }
                    .font(.system(size: 12, weight: .black, design: .rounded))
                    .foregroundColor(Color(hex: item.category.tintHex))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Color(hex: item.category.tintHex).opacity(0.15))
                    .clipShape(Capsule())

                    if let distanceKm {
                        Text(String(format: "%.0fkm圏", distanceKm))
                            .font(.system(size: 12, weight: .black, design: .rounded))
                            .foregroundColor(.jfCyan)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(Color.jfCyan.opacity(0.15))
                            .clipShape(Capsule())
                    }

                    Spacer()

                    Button(action: onSave) {
                        Image(systemName: isSaved ? "bookmark.fill" : "bookmark")
                            .font(.system(size: 17, weight: .bold))
                            .foregroundColor(isSaved ? .jfAmber : .jfSubtext)
                    }
                    .buttonStyle(.plain)
                }

                Text(item.title)
                    .font(.system(size: 18, weight: .black, design: .rounded))
                    .foregroundColor(.jfText)
                    .multilineTextAlignment(.leading)
                    .lineLimit(3)

                Text(item.summaryPoints.first ?? item.description)
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(.jfSubtext)
                    .multilineTextAlignment(.leading)
                    .lineLimit(2)

                HStack(spacing: 10) {
                    MetaPill(icon: "clock.fill", text: item.timeAgo)
                    MetaPill(icon: "newspaper.fill", text: item.sources.first ?? item.source)
                    Spacer()
                    Label("分析", systemImage: "arrow.right.circle.fill")
                        .font(.system(size: 13, weight: .black, design: .rounded))
                        .foregroundColor(.jfRed)
                }
        }
        .glassCard()
        .overlay(alignment: .leading) {
            RoundedRectangle(cornerRadius: 2)
                .fill(Color(hex: item.category.tintHex))
                .frame(width: 4)
                .padding(.vertical, 20)
        }
        .contentShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .onTapGesture(perform: onOpen)
    }
}

private struct MetaPill: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: 5) {
            Image(systemName: icon)
            Text(text)
                .lineLimit(1)
        }
        .font(.system(size: 11, weight: .bold, design: .rounded))
        .foregroundColor(.jfSubtext)
    }
}

struct AlertDetailView: View {
    let item: NewsItem
    let isSaved: Bool
    let onSave: () -> Void
    var embedded = false

    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                if !embedded {
                    HStack {
                        Spacer()
                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "xmark")
                                .font(.system(size: 14, weight: .black))
                                .foregroundColor(.jfText)
                                .frame(width: 36, height: 36)
                                .background(Color.white.opacity(0.1))
                                .clipShape(Circle())
                        }
                    }
                }

                DetailHero(item: item)

                ActionBar(item: item, isSaved: isSaved, onSave: onSave) {
                    if let url = URL(string: item.url) {
                        openURL(url)
                    }
                }

                DetailArtwork(imageName: "jiken-analysis", title: "要点整理", caption: "見出しだけで判断しないための確認欄")

                DetailSection(title: "要点", icon: "list.bullet.rectangle.fill", tint: .jfCyan) {
                    VStack(alignment: .leading, spacing: 10) {
                        ForEach(Array(item.summaryPoints.enumerated()), id: \.offset) { index, point in
                            NumberedPoint(number: index + 1, text: point)
                        }
                    }
                }

                DetailSection(title: "安全メモ", icon: "shield.checkered", tint: .jfRed) {
                    VStack(alignment: .leading, spacing: 10) {
                        ForEach(item.safetyActions, id: \.self) { action in
                            Label(action, systemImage: "checkmark.circle.fill")
                                .font(.system(size: 14, weight: .bold, design: .rounded))
                                .foregroundColor(.jfText)
                        }
                    }
                }

                DetailArtwork(imageName: "jiken-map-context", title: "場所の文脈", caption: "近い可能性がある情報は距離感も確認")

                DetailSection(title: "確認の流れ", icon: "clock.arrow.circlepath", tint: .jfAmber) {
                    AlertTimelineView(item: item)
                }

                Text("このアプリは速報を整理する補助ツールです。緊急時は警察、消防、自治体、交通機関など公的な発表を優先してください。")
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundColor(.jfSubtext)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.bottom, 20)
            }
            .padding(embedded ? 22 : 18)
        }
        .background(JFBackground())
    }
}

private struct DetailHero: View {
    let item: NewsItem

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text(item.riskLabel)
                    .font(.system(size: 13, weight: .black, design: .rounded))
                    .foregroundColor(.jfText)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 7)
                    .background(Color(hex: item.category.tintHex))
                    .clipShape(Capsule())
                Text(item.category.label)
                    .font(.system(size: 13, weight: .black, design: .rounded))
                    .foregroundColor(Color(hex: item.category.tintHex))
                Spacer()
            }

            Text(item.title)
                .font(.system(size: 28, weight: .black, design: .rounded))
                .foregroundColor(.jfText)
                .fixedSize(horizontal: false, vertical: true)

            Text("\(item.timeAgo) ・ \(item.sources.joined(separator: " / "))")
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .foregroundColor(.jfSubtext)
        }
        .glassCard(padding: 18)
    }
}

private struct ActionBar: View {
    let item: NewsItem
    let isSaved: Bool
    let onSave: () -> Void
    let openSource: () -> Void

    var body: some View {
        HStack(spacing: 10) {
            Button(action: onSave) {
                Label(isSaved ? "保存済み" : "保存", systemImage: isSaved ? "bookmark.fill" : "bookmark")
            }
            Button(action: openSource) {
                Label("出典を開く", systemImage: "safari.fill")
            }
        }
        .font(.system(size: 14, weight: .black, design: .rounded))
        .foregroundColor(.jfText)
        .buttonStyle(.borderedProminent)
        .tint(.jfRed)
    }
}

private struct DetailArtwork: View {
    let imageName: String
    let title: String
    let caption: String

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            Image(imageName)
                .resizable()
                .scaledToFill()
                .frame(height: 180)
                .clipped()
            LinearGradient(colors: [.clear, .black.opacity(0.78)], startPoint: .center, endPoint: .bottom)
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 18, weight: .black, design: .rounded))
                    .foregroundColor(.jfText)
                Text(caption)
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundColor(.jfSubtext)
            }
            .padding(16)
        }
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
    }
}

private struct DetailSection<Content: View>: View {
    let title: String
    let icon: String
    let tint: Color
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .foregroundColor(tint)
                Text(title)
                    .font(.system(size: 17, weight: .black, design: .rounded))
                    .foregroundColor(.jfText)
            }
            content
        }
        .glassCard()
    }
}

private struct NumberedPoint: View {
    let number: Int
    let text: String

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Text("\(number)")
                .font(.system(size: 12, weight: .black, design: .rounded))
                .foregroundColor(.jfBlack)
                .frame(width: 24, height: 24)
                .background(Color.jfCyan)
                .clipShape(Circle())
            Text(text)
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundColor(.jfText)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

private struct AlertTimelineView: View {
    let item: NewsItem

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            TimelineRow(title: "速報を受信", detail: item.timeAgo, tint: .jfRed)
            TimelineRow(title: "要点を整理", detail: "本文から確認ポイントを抽出", tint: .jfCyan)
            TimelineRow(title: "行動メモを確認", detail: "カテゴリ別の安全行動を表示", tint: .jfAmber)
        }
    }
}

private struct TimelineRow: View {
    let title: String
    let detail: String
    let tint: Color

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Circle()
                .fill(tint)
                .frame(width: 10, height: 10)
                .padding(.top, 5)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 14, weight: .black, design: .rounded))
                    .foregroundColor(.jfText)
                Text(detail)
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundColor(.jfSubtext)
            }
        }
    }
}
