import CoreLocation
import Foundation
import SwiftUI

@MainActor
final class NewsService: ObservableObject {
    @Published var items: [NewsItem] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var lastUpdated: Date?

    private let baseURL = "https://jiken-flash.vercel.app/api/news"

    func fetchNews(category: NewsCategory = .all) async {
        isLoading = true
        errorMessage = nil

        var urlString = baseURL
        if category != .all && category != .nearby {
            urlString += "?category=\(category.rawValue)"
        }

        guard let url = URL(string: urlString) else {
            items = Self.mockItems
            errorMessage = "ニュースURLを確認してください。"
            isLoading = false
            return
        }

        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
                throw URLError(.badServerResponse)
            }
            let newsResponse = try JSONDecoder().decode(NewsResponse.self, from: data)
            items = newsResponse.items
            lastUpdated = Date()
        } catch {
            items = Self.mockItems
            errorMessage = "通信できないため、サンプル表示に切り替えました。"
            lastUpdated = Date()
        }

        isLoading = false
    }

    static let mockItems: [NewsItem] = [
        NewsItem(id: "sample1", title: "新宿区で不審者情報、周辺の通学路で見守り強化", description: "警察と自治体が周辺の巡回を強化。夜間の一人歩きや人通りの少ない道を避けるよう呼びかけています。", url: "https://example.com/1", source: "地域安全情報", sources: ["地域安全情報", "自治体発表"], category: .crime, publishedAt: "2026-05-08T08:20:00Z", fetchedAt: "2026-05-08T08:22:00Z"),
        NewsItem(id: "sample2", title: "首都高速で事故渋滞、都心方面は迂回推奨", description: "事故処理のため一部車線で規制。通勤時間帯は周辺道路も混雑する見込みです。", url: "https://example.com/2", source: "交通情報", sources: ["交通情報", "道路管制"], category: .traffic, publishedAt: "2026-05-08T07:40:00Z", fetchedAt: "2026-05-08T07:42:00Z"),
        NewsItem(id: "sample3", title: "東京湾を震源とする地震、強い揺れへの注意を呼びかけ", description: "気象庁は今後の情報に注意し、家具の固定や避難経路を確認するよう案内しています。", url: "https://example.com/3", source: "防災速報", sources: ["防災速報", "気象庁"], category: .earthquake, publishedAt: "2026-05-08T06:55:00Z", fetchedAt: "2026-05-08T06:56:00Z"),
        NewsItem(id: "sample4", title: "横浜市内で建物火災、周辺道路で通行規制", description: "消防が消火活動を行っています。煙が流れる地域では窓を閉め、現場付近を避けてください。", url: "https://example.com/4", source: "消防情報", sources: ["消防情報"], category: .fire, publishedAt: "2026-05-08T05:10:00Z", fetchedAt: "2026-05-08T05:12:00Z"),
        NewsItem(id: "sample5", title: "中央線快速に遅れ、振替輸送を実施", description: "設備点検の影響で一部列車に遅れ。駅の混雑が予想されます。", url: "https://example.com/5", source: "鉄道運行情報", sources: ["鉄道運行情報"], category: .train, publishedAt: "2026-05-08T04:45:00Z", fetchedAt: "2026-05-08T04:46:00Z")
    ]
}

@MainActor
final class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    static let shared = LocationManager()

    private let manager = CLLocationManager()
    @Published var location: CLLocation?
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyKilometer
    }

    func requestPermission() {
        manager.requestWhenInUseAuthorization()
    }

    func requestLocation() {
        manager.requestLocation()
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        Task { @MainActor in
            self.location = location
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location error: \(error.localizedDescription)")
    }

    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        Task { @MainActor in
            self.authorizationStatus = manager.authorizationStatus
            if manager.authorizationStatus == .authorizedWhenInUse || manager.authorizationStatus == .authorizedAlways {
                self.manager.requestLocation()
            }
        }
    }
}

@MainActor
final class SavedAlertStore: ObservableObject {
    @Published private(set) var savedIDs: Set<String> = []
    private let key = "savedAlertIDs"

    init() {
        savedIDs = Set(UserDefaults.standard.stringArray(forKey: key) ?? [])
    }

    func toggle(_ item: NewsItem) {
        if savedIDs.contains(item.id) {
            savedIDs.remove(item.id)
        } else {
            savedIDs.insert(item.id)
        }
        UserDefaults.standard.set(Array(savedIDs), forKey: key)
    }

    func isSaved(_ item: NewsItem) -> Bool {
        savedIDs.contains(item.id)
    }
}

final class ThemeManager: ObservableObject {
    static let shared = ThemeManager()
    @AppStorage("isDarkMode") var isDarkMode = true
}
