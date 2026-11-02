import SwiftUI

@main
struct KUDotApp: App {
    @StateObject private var store = PlaceStore()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(store)
                .tint(AppTheme.green)
        }
    }
}

enum AppTheme {
    static let green = Color(red: 0.14, green: 0.42, blue: 0.31)
    static let crimson = Color(red: 0.56, green: 0.08, blue: 0.19)
    static let background = Color(red: 0.96, green: 0.97, blue: 0.95)
}
