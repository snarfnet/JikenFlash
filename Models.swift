import CoreLocation
import Foundation

enum NewsCategory: String, Codable, CaseIterable, Identifiable {
    case all
    case nearby
    case crime
    case traffic
    case fire
    case disaster
    case train
    case earthquake
    case other

    var id: String { rawValue }

    var label: String {
        switch self {
        case .all: return "総合"
        case .nearby: return "近く"
        case .crime: return "事件"
        case .traffic: return "交通"
        case .fire: return "火災"
        case .disaster: return "災害"
        case .train: return "鉄道"
        case .earthquake: return "地震"
        case .other: return "その他"
        }
    }

    var icon: String {
        switch self {
        case .all: return "rectangle.grid.2x2.fill"
        case .nearby: return "location.fill"
        case .crime: return "exclamationmark.shield.fill"
        case .traffic: return "car.fill"
        case .fire: return "flame.fill"
        case .disaster: return "tornado"
        case .train: return "tram.fill"
        case .earthquake: return "waveform.path.ecg"
        case .other: return "ellipsis.circle.fill"
        }
    }

    var tintHex: String {
        switch self {
        case .all: return "#F3F4F6"
        case .nearby: return "#22D3EE"
        case .crime: return "#FB2C36"
        case .traffic: return "#F59E0B"
        case .fire: return "#FF5C35"
        case .disaster: return "#60A5FA"
        case .train: return "#38BDF8"
        case .earthquake: return "#F97316"
        case .other: return "#94A3B8"
        }
    }

    static var tabs: [NewsCategory] {
        [.all, .nearby, .crime, .traffic, .fire, .disaster, .train, .earthquake]
    }
}

struct NewsItem: Codable, Identifiable, Hashable {
    let id: String
    let title: String
    let description: String
    let url: String
    let source: String
    let sources: [String]
    let category: NewsCategory
    let publishedAt: String
    let fetchedAt: String

    init(id: String, title: String, description: String, url: String, source: String, sources: [String], category: NewsCategory, publishedAt: String, fetchedAt: String) {
        self.id = id
        self.title = title
        self.description = description
        self.url = url
        self.source = source
        self.sources = sources
        self.category = category
        self.publishedAt = publishedAt
        self.fetchedAt = fetchedAt
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        description = (try? container.decode(String.self, forKey: .description)) ?? ""
        url = try container.decode(String.self, forKey: .url)
        source = (try? container.decode(String.self, forKey: .source)) ?? ""
        sources = (try? container.decode([String].self, forKey: .sources)) ?? [source].filter { !$0.isEmpty }
        publishedAt = try container.decode(String.self, forKey: .publishedAt)
        fetchedAt = (try? container.decode(String.self, forKey: .fetchedAt)) ?? publishedAt
        let categoryString = (try? container.decode(String.self, forKey: .category)) ?? "other"
        category = NewsCategory(rawValue: categoryString) ?? .other
    }

    var publishedDate: Date? {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = formatter.date(from: publishedAt) { return date }
        formatter.formatOptions = [.withInternetDateTime]
        return formatter.date(from: publishedAt)
    }

    var timeAgo: String {
        guard let date = publishedDate else { return "更新時刻不明" }
        let seconds = max(0, Int(Date().timeIntervalSince(date)))
        if seconds < 60 { return "たった今" }
        if seconds < 3600 { return "\(seconds / 60)分前" }
        if seconds < 86400 { return "\(seconds / 3600)時間前" }
        return "\(seconds / 86400)日前"
    }

    var summaryPoints: [String] {
        let base = description.isEmpty ? title : description
        let fragments = base
            .replacingOccurrences(of: "。", with: "。|")
            .replacingOccurrences(of: "、", with: "、|")
            .split(separator: "|")
            .map { String($0).trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        let derived = fragments.prefix(3)
        if derived.isEmpty {
            return ["内容を確認中です。", "複数ソースで続報を確認してください。", "近くで起きた可能性がある場合は自治体情報も確認してください。"]
        }
        return Array(derived)
    }

    var safetyActions: [String] {
        switch category {
        case .crime:
            return ["現場周辺に近づかない", "夜間は明るい道を選ぶ", "不安があれば警察・自治体情報を確認"]
        case .traffic:
            return ["迂回ルートを確認", "移動時間に余裕を持つ", "現地の交通規制を確認"]
        case .fire:
            return ["煙の方向を避ける", "近隣なら窓を閉める", "消防・自治体の続報を確認"]
        case .disaster, .earthquake:
            return ["身の安全を優先", "避難経路と家族連絡を確認", "公的情報を見て行動"]
        case .train:
            return ["代替路線を確認", "駅の混雑を避ける", "運行会社の情報を確認"]
        default:
            return ["見出しだけで判断しない", "出典を確認", "必要なら保存して後で確認"]
        }
    }

    var riskLabel: String {
        switch category {
        case .crime, .fire, .earthquake: return "注意"
        case .traffic, .disaster, .train: return "確認"
        default: return "情報"
        }
    }
}

struct NewsResponse: Codable {
    let items: [NewsItem]
    let lastUpdated: String
    let totalCount: Int
}

struct PrefectureLocation {
    let name: String
    let lat: Double
    let lon: Double
}

let prefectureLocations: [PrefectureLocation] = [
    PrefectureLocation(name: "北海道", lat: 43.06, lon: 141.35),
    PrefectureLocation(name: "青森", lat: 40.82, lon: 140.74),
    PrefectureLocation(name: "岩手", lat: 39.70, lon: 141.15),
    PrefectureLocation(name: "宮城", lat: 38.27, lon: 140.87),
    PrefectureLocation(name: "秋田", lat: 39.72, lon: 140.10),
    PrefectureLocation(name: "山形", lat: 38.24, lon: 140.34),
    PrefectureLocation(name: "福島", lat: 37.75, lon: 140.47),
    PrefectureLocation(name: "茨城", lat: 36.34, lon: 140.45),
    PrefectureLocation(name: "栃木", lat: 36.57, lon: 139.88),
    PrefectureLocation(name: "群馬", lat: 36.39, lon: 139.06),
    PrefectureLocation(name: "埼玉", lat: 35.86, lon: 139.65),
    PrefectureLocation(name: "千葉", lat: 35.60, lon: 140.12),
    PrefectureLocation(name: "東京", lat: 35.68, lon: 139.69),
    PrefectureLocation(name: "神奈川", lat: 35.45, lon: 139.64),
    PrefectureLocation(name: "大阪", lat: 34.69, lon: 135.50),
    PrefectureLocation(name: "名古屋", lat: 35.18, lon: 136.91),
    PrefectureLocation(name: "福岡", lat: 33.59, lon: 130.40),
    PrefectureLocation(name: "新宿", lat: 35.69, lon: 139.70),
    PrefectureLocation(name: "渋谷", lat: 35.66, lon: 139.70),
    PrefectureLocation(name: "池袋", lat: 35.73, lon: 139.71),
    PrefectureLocation(name: "横浜", lat: 35.44, lon: 139.64),
    PrefectureLocation(name: "川崎", lat: 35.53, lon: 139.70)
]

func distanceToNews(from userLocation: CLLocation, newsText: String) -> Double? {
    var nearest: Double?
    for location in prefectureLocations where newsText.contains(location.name) {
        let target = CLLocation(latitude: location.lat, longitude: location.lon)
        let distance = userLocation.distance(from: target) / 1000.0
        if nearest == nil || distance < nearest! {
            nearest = distance
        }
    }
    return nearest
}
