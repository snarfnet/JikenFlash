import AppTrackingTransparency
import GoogleMobileAds
import SwiftUI

final class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        true
    }
}

@MainActor
final class AdMobStartup: ObservableObject {
    static let shared = AdMobStartup()

    @Published private(set) var isReady = false
    private var didStart = false

    func requestTrackingAndStartAds() async {
        guard !didStart else { return }
        didStart = true

        try? await Task.sleep(for: .milliseconds(700))

        if #available(iOS 14.5, *) {
            await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
                ATTrackingManager.requestTrackingAuthorization { _ in
                    continuation.resume()
                }
            }
        }

        MobileAds.shared.start { [weak self] _ in
            Task { @MainActor in
                self?.isReady = true
            }
        }
    }
}
