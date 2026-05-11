import GoogleMobileAds
import SwiftUI

struct BannerAdView: UIViewRepresentable {
    let adUnitID: String
    let adSize: AdSize

    func makeUIView(context: Context) -> BannerView {
        let bannerView = BannerView(adSize: adSize)
        bannerView.adUnitID = adUnitID
        return bannerView
    }

    func updateUIView(_ uiView: BannerView, context: Context) {
        guard uiView.rootViewController == nil else { return }
        if let scene = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene }).first,
           let rootVC = scene.keyWindow?.rootViewController {
            uiView.rootViewController = rootVC
            uiView.load(Request())
        }
    }
}

struct AdBannerView: View {
    var body: some View {
        GeometryReader { geo in
            if geo.size.width > 0 {
                BannerAdView(
                    adUnitID: "ca-app-pub-9404799280370656/8537932771",
                    adSize: currentOrientationAnchoredAdaptiveBanner(width: geo.size.width)
                )
            }
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
