import GoogleMobileAds
import SwiftUI

struct BannerAdView: UIViewRepresentable {
    let adUnitID: String
    let adSize: AdSize

    func makeUIView(context: Context) -> BannerView {
        let bannerView = BannerView(adSize: adSize)
        bannerView.adUnitID = adUnitID
        DispatchQueue.main.async {
            if let windowScene = bannerView.window?.windowScene,
               let rootVC = windowScene.keyWindow?.rootViewController {
                bannerView.rootViewController = rootVC
            }
            bannerView.load(Request())
        }
        return bannerView
    }

    func updateUIView(_ uiView: BannerView, context: Context) {}
}

struct AdBannerView: View {
    var body: some View {
        GeometryReader { geo in
            BannerAdView(
                adUnitID: "ca-app-pub-9404799280370656/8537932771",
                adSize: currentOrientationAnchoredAdaptiveBanner(width: geo.size.width)
            )
        }
        .frame(height: 54)
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
