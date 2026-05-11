import AppTrackingTransparency
import GoogleMobileAds
import SwiftUI

final class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        // Defer AdMob init to avoid crash on iPadOS 26
        DispatchQueue.main.async {
            MobileAds.shared.start { _ in
                print("AdMob SDK initialized")
            }
        }
        return true
    }
}

@MainActor
final class TrackingConsentManager: ObservableObject {
    static let shared = TrackingConsentManager()

    @Published private(set) var didResolveConsent = false

    func requestBeforeAds() async {
        guard !didResolveConsent else { return }

        try? await Task.sleep(for: .seconds(1))

        if #available(iOS 14.5, *) {
            await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
                ATTrackingManager.requestTrackingAuthorization { _ in
                    continuation.resume()
                }
            }
        }

        didResolveConsent = true
    }
}
