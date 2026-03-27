import SwiftUI

@main
struct QueimaPancaWatchApp: App {
    @StateObject private var watchVM = WatchViewModel()

    var body: some Scene {
        WindowGroup {
            WatchHomeView()
                .environmentObject(watchVM)
        }
    }
}
