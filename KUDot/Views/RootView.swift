import SwiftUI

struct RootView: View {
    var body: some View {
        TabView {
            CampusMapView()
                .tabItem { Label("KU돗 지도", systemImage: "map.fill") }

            RecommendationView()
                .tabItem { Label("장소 추천", systemImage: "sparkles") }

            SightingView()
                .tabItem { Label("발견 기록", systemImage: "pawprint.fill") }

            ArchiveView()
                .tabItem { Label("쉼터 모음", systemImage: "square.stack.fill") }
        }
    }
}
