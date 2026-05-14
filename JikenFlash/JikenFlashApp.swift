import SwiftUI

@main
struct JikenFlashApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var adMobStartup = AdMobStartup.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    Task {
                        await adMobStartup.startAdsAfterLaunch()
                    }
                }
        }
    }
}
