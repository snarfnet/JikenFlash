import GoogleMobileAds
import SwiftUI

struct BannerAdView: UIViewRepresentable {
    let adUnitID: String
    let adSize: AdSize

    func makeUIView(context: Context) -> UIView {
        let container = UIView()
        container.backgroundColor = .clear
        let bannerView = BannerView(adSize: adSize)
        bannerView.adUnitID = adUnitID
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(bannerView)
        NSLayoutConstraint.activate([
            bannerView.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            bannerView.centerYAnchor.constraint(equalTo: container.centerYAnchor),
        ])
        context.coordinator.bannerView = bannerView
        return container
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        guard let bannerView = context.coordinator.bannerView,
              bannerView.rootViewController == nil else { return }
        if let rootVC = uiView.window?.rootViewController {
            bannerView.rootViewController = rootVC
            bannerView.load(Request())
        }
    }

    func makeCoordinator() -> Coordinator { Coordinator() }

    final class Coordinator {
        var bannerView: BannerView?
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
