import SwiftUI

struct ContentView: View {
    @StateObject private var newsService = NewsService()
    @StateObject private var adManager = AdRemovalManager.shared
    @StateObject private var locationManager = LocationManager.shared
    @StateObject private var savedStore = SavedAlertStore()
    @StateObject private var tracking = TrackingConsentManager.shared

    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @State private var selectedCategory: NewsCategory = .all
    @State private var selectedItem: NewsItem?
    @State private var showSettings = false
    @State private var searchText = ""

    var body: some View {
        Group {
            if horizontalSizeClass == .regular {
                iPadLayout
            } else {
                iPhoneLayout
            }
        }
        .preferredColorScheme(.dark)
        .sheet(isPresented: $showSettings) {
            SettingsView(adManager: adManager)
        }
        .task {
            await tracking.requestBeforeAds()
            await newsService.fetchNews()
        }
        .onChange(of: selectedCategory) { _, newValue in
            if newValue == .nearby {
                locationManager.requestPermission()
                locationManager.requestLocation()
            }
            Task { await newsService.fetchNews(category: newValue) }
        }
    }

    private var iPhoneLayout: some View {
        NavigationStack {
            ZStack {
                JFBackground()
                ScrollView {
                    VStack(spacing: 18) {
                        HeaderHero(showSettings: { showSettings = true })
                        NativeValueStrip()
                        CategoryCarousel(selected: $selectedCategory)
                        SearchBar(text: $searchText)

                        if !adManager.isAdFree && tracking.didResolveConsent {
                            AdBannerView()
                                .frame(height: 54)
                                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                                .padding(.horizontal, 16)
                        }

                        if newsService.isLoading && newsService.items.isEmpty {
                            LoadingPanel()
                        } else {
                            ForEach(filteredItems) { item in
                                NewsCardView(
                                    item: item,
                                    distanceKm: distanceForItem(item),
                                    isSaved: savedStore.isSaved(item),
                                    onSave: { savedStore.toggle(item) },
                                    onOpen: { selectedItem = item }
                                )
                                .padding(.horizontal, 16)
                            }
                        }
                    }
                    .padding(.vertical, 14)
                }
                .refreshable { await newsService.fetchNews(category: selectedCategory) }
            }
            .navigationBarHidden(true)
            .sheet(item: $selectedItem) { item in
                AlertDetailView(item: item, isSaved: savedStore.isSaved(item), onSave: { savedStore.toggle(item) })
            }
        }
    }

    private var iPadLayout: some View {
        NavigationSplitView {
            ZStack {
                JFBackground()
                VStack(alignment: .leading, spacing: 16) {
                    HeaderMini(showSettings: { showSettings = true })
                    CategorySidebar(selected: $selectedCategory)
                    NativeValueStrip(compact: true)
                    Spacer()
                }
                .padding(18)
            }
            .navigationBarHidden(true)
        } content: {
            ZStack {
                JFBackground()
                ScrollView {
                    VStack(spacing: 16) {
                        SearchBar(text: $searchText)
                        if !adManager.isAdFree && tracking.didResolveConsent {
                            AdBannerView()
                                .frame(height: 54)
                                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                                .padding(.horizontal, 16)
                        }
                        ForEach(filteredItems) { item in
                            NewsCardView(
                                item: item,
                                distanceKm: distanceForItem(item),
                                isSaved: savedStore.isSaved(item),
                                onSave: { savedStore.toggle(item) },
                                onOpen: { selectedItem = item }
                            )
                            .padding(.horizontal, 16)
                        }
                    }
                    .padding(.vertical, 18)
                }
            }
            .navigationTitle("速報一覧")
        } detail: {
            ZStack {
                JFBackground()
                if let item = selectedItem ?? filteredItems.first {
                    AlertDetailView(item: item, isSaved: savedStore.isSaved(item), onSave: { savedStore.toggle(item) }, embedded: true)
                } else {
                    EmptyDetailPanel()
                }
            }
        }
    }

    private var filteredItems: [NewsItem] {
        var result = newsService.items
        if selectedCategory == .nearby {
            if let userLocation = locationManager.location {
                result = result
                    .compactMap { item -> (NewsItem, Double)? in
                        guard let distance = distanceToNews(from: userLocation, newsText: "\(item.title) \(item.description)") else { return nil }
                        return (item, distance)
                    }
                    .sorted { $0.1 < $1.1 }
                    .map(\.0)
            }
        } else if selectedCategory != .all {
            result = result.filter { $0.category == selectedCategory }
        }
        if !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            result = result.filter { "\($0.title) \($0.description)".localizedCaseInsensitiveContains(searchText) }
        }
        return result
    }

    private func distanceForItem(_ item: NewsItem) -> Double? {
        guard let userLocation = locationManager.location else { return nil }
        return distanceToNews(from: userLocation, newsText: "\(item.title) \(item.description)")
    }
}

private struct HeaderHero: View {
    let showSettings: () -> Void

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            Image("jiken-newsroom")
                .resizable()
                .scaledToFill()
                .frame(height: 260)
                .clipped()
            LinearGradient(colors: [.black.opacity(0.05), .black.opacity(0.82)], startPoint: .top, endPoint: .bottom)
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text("LIVE ANALYSIS")
                        .font(.system(size: 11, weight: .black, design: .rounded))
                        .tracking(2)
                        .foregroundColor(.jfCyan)
                    Spacer()
                    Button(action: showSettings) {
                        Image(systemName: "gearshape.fill")
                            .foregroundColor(.jfText)
                            .frame(width: 38, height: 38)
                            .background(Color.white.opacity(0.12))
                            .clipShape(Circle())
                    }
                }
                Text("事件速報")
                    .font(.system(size: 42, weight: .black, design: .rounded))
                    .foregroundColor(.jfText)
                Text("ニュースを開く前に、要点・距離・安全メモを整理します。")
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundColor(.jfSubtext)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(20)
        }
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        .padding(.horizontal, 16)
    }
}

private struct HeaderMini: View {
    let showSettings: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Image("jiken-icon-art")
                .resizable()
                .scaledToFill()
                .frame(width: 64, height: 64)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            Text("事件速報")
                .font(.system(size: 30, weight: .black, design: .rounded))
                .foregroundColor(.jfText)
            Text("速報を整理して、安全な判断に変える")
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundColor(.jfSubtext)
            Button(action: showSettings) {
                Label("設定", systemImage: "gearshape.fill")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundColor(.jfText)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(Color.white.opacity(0.1))
                    .clipShape(Capsule())
            }
        }
    }
}

private struct NativeValueStrip: View {
    var compact = false

    var body: some View {
        let columns = compact ? [GridItem(.flexible())] : [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]
        LazyVGrid(columns: columns, spacing: 10) {
            ValueCard(icon: "list.bullet.rectangle.fill", title: "要点", value: "3点整理", tint: .jfCyan)
            ValueCard(icon: "shield.checkered", title: "安全メモ", value: "行動確認", tint: .jfRed)
            ValueCard(icon: "bookmark.fill", title: "保存", value: "あとで確認", tint: .jfAmber)
        }
        .padding(.horizontal, compact ? 0 : 16)
    }
}

private struct ValueCard: View {
    let icon: String
    let title: String
    let value: String
    let tint: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: icon)
                .foregroundColor(tint)
            Text(title)
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .foregroundColor(.jfSubtext)
            Text(value)
                .font(.system(size: 15, weight: .black, design: .rounded))
                .foregroundColor(.jfText)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .glassCard(padding: 12)
    }
}

private struct CategoryCarousel: View {
    @Binding var selected: NewsCategory

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(NewsCategory.tabs) { category in
                    CategoryChip(category: category, isSelected: selected == category) {
                        withAnimation(.spring(response: 0.28, dampingFraction: 0.85)) {
                            selected = category
                        }
                    }
                }
            }
            .padding(.horizontal, 16)
        }
    }
}

private struct CategorySidebar: View {
    @Binding var selected: NewsCategory

    var body: some View {
        VStack(spacing: 8) {
            ForEach(NewsCategory.tabs) { category in
                CategoryChip(category: category, isSelected: selected == category, wide: true) {
                    selected = category
                }
            }
        }
    }
}

private struct CategoryChip: View {
    let category: NewsCategory
    let isSelected: Bool
    var wide = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 7) {
                Image(systemName: category.icon)
                Text(category.label)
                if wide { Spacer() }
            }
            .font(.system(size: 14, weight: .bold, design: .rounded))
            .foregroundColor(isSelected ? .jfText : .jfSubtext)
            .padding(.horizontal, 14)
            .padding(.vertical, 11)
            .frame(maxWidth: wide ? .infinity : nil, alignment: .leading)
            .background(isSelected ? Color(hex: category.tintHex).opacity(0.24) : Color.white.opacity(0.07))
            .clipShape(Capsule())
            .overlay(Capsule().stroke(isSelected ? Color(hex: category.tintHex).opacity(0.55) : .clear, lineWidth: 1))
        }
        .buttonStyle(.plain)
    }
}

private struct SearchBar: View {
    @Binding var text: String

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.jfSubtext)
            TextField("キーワードで絞り込み", text: $text)
                .textInputAutocapitalization(.never)
                .foregroundColor(.jfText)
        }
        .padding(14)
        .background(Color.white.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .padding(.horizontal, 16)
    }
}

private struct LoadingPanel: View {
    var body: some View {
        VStack(spacing: 14) {
            ProgressView()
                .tint(.jfRed)
                .scaleEffect(1.25)
            Text("速報を整理しています")
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .foregroundColor(.jfText)
        }
        .frame(maxWidth: .infinity)
        .glassCard()
        .padding(.horizontal, 16)
    }
}

private struct EmptyDetailPanel: View {
    var body: some View {
        VStack(spacing: 16) {
            Image("jiken-flow")
                .resizable()
                .scaledToFit()
                .frame(maxWidth: 360)
                .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
            Text("記事を選ぶと分析が表示されます")
                .font(.system(size: 18, weight: .black, design: .rounded))
                .foregroundColor(.jfText)
        }
        .padding(24)
    }
}

#Preview {
    ContentView()
}
