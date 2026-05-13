import GoogleMobileAds
import SwiftUI
import UIKit

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
        if let rootVC = UIApplication.shared.adRootViewController {
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
    @ObservedObject private var adMobStartup = AdMobStartup.shared

    var body: some View {
        GeometryReader { geo in
            if adMobStartup.isReady, geo.size.width > 0 {
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
    @ObservedObject private var adMobStartup = AdMobStartup.shared

    var body: some View {
        if adMobStartup.isReady {
            BannerAdView(
                adUnitID: "ca-app-pub-9404799280370656/8537932771",
                adSize: AdSizeMediumRectangle
            )
        }
    }
}

private extension UIApplication {
    var adRootViewController: UIViewController? {
        connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap(\.windows)
            .first { $0.isKeyWindow }?
            .rootViewController
    }
}
