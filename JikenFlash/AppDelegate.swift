import AppTrackingTransparency
import GoogleMobileAds
import SwiftUI

final class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        return true
    }
}

@MainActor
final class TrackingConsentManager: ObservableObject {
    static let shared = TrackingConsentManager()

    @Published private(set) var didResolveConsent = false
    private var didStartAds = false

    func requestBeforeAds() async {
        guard !didResolveConsent else {
            startAdsIfNeeded()
            return
        }

        try? await Task.sleep(for: .seconds(1))

        if #available(iOS 14.5, *) {
            await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
                ATTrackingManager.requestTrackingAuthorization { _ in
                    continuation.resume()
                }
            }
        }

        didResolveConsent = true
        startAdsIfNeeded()
    }

    private func startAdsIfNeeded() {
        guard !didStartAds else { return }
        didStartAds = true
        MobileAds.shared.start(completionHandler: nil)
    }
}
