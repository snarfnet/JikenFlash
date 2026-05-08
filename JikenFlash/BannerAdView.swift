import GoogleMobileAds
import SwiftUI

struct BannerAdView: UIViewRepresentable {
    let adUnitID: String
    let adSize: AdSize

    func makeUIView(context: Context) -> BannerView {
        let bannerView = BannerView(adSize: adSize)
        bannerView.adUnitID = adUnitID
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootVC = windowScene.windows.first(where: { $0.isKeyWindow })?.rootViewController {
            bannerView.rootViewController = rootVC
        }
        bannerView.load(Request())
        return bannerView
    }

    func updateUIView(_ uiView: BannerView, context: Context) {}
}

struct AdBannerView: View {
    var body: some View {
        BannerAdView(
            adUnitID: "ca-app-pub-9404799280370656/8537932771",
            adSize: currentOrientationAnchoredAdaptiveBanner(width: UIScreen.main.bounds.width)
        )
    }
}

struct LargeAdBannerView: View {
    var body: some View {
        BannerAdView(
            adUnitID: "ca-app-pub-9404799280370656/8537932771",
            adSize: AdSizeMediumRectangle
        )
    }
}
