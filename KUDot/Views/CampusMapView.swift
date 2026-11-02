import SwiftUI
import MapKit

struct CampusMapView: View {
    @EnvironmentObject private var store: PlaceStore

    @State private var cameraPosition: MapCameraPosition = .region(
        MKCoordinateRegion(center: CampusData.center,
                           span: MKCoordinateSpan(latitudeDelta: 0.0055,
                                                  longitudeDelta: 0.0065))
    )
    @State private var mapCenter = CampusData.center
    @State private var selectedPlace: PlaceRecord?
    @State private var selectedBuilding: CampusBuilding?
    @State private var selectedReport: FieldReport?
    @State private var reportFilter: FieldReportKind?
    @State private var showReports = true
    @State private var filter: PlaceCategory?
    @State private var showBuildings = true
    @State private var hybrid = false
    @State private var showingAdd = false
    @State private var showingReportAdd = false

    private var visiblePlaces: [PlaceRecord] {
        store.places.filter { filter == nil || $0.category == filter }
    }

    private var visibleReports: [FieldReport] {
        guard showReports else { return [] }
        return store.reports.filter { reportFilter == nil || $0.kind == reportFilter }
    }

    var body: some View {
        ZStack(alignment: .top) {
            Map(position: $cameraPosition) {
                if showBuildings {
                    ForEach(CampusData.buildings) { building in
                        Annotation(building.name, coordinate: building.coordinate, anchor: .bottom) {
                            Button {
                                selectedBuilding = building
                            } label: {
                                VStack(spacing: 2) {
                                    Image(systemName: "building.2.crop.circle.fill")
                                        .font(.system(size: 22))
                                        .foregroundStyle(AppTheme.crimson)
                                        .background(Circle().fill(.white).padding(2))
                                    Text(building.name)
                                        .font(.system(size: 9, weight: .bold))
                                        .lineLimit(1)
                                        .padding(.horizontal, 5)
                                        .padding(.vertical, 3)
                                        .background(.white.opacity(0.96), in: Capsule())
                                        .foregroundStyle(.black)
                                }
                            }
                            .buttonStyle(.plain)
                            .accessibilityLabel("건물: \(building.name)")
                        }
                        .annotationTitles(.hidden)
                    }
                }
                ForEach(visiblePlaces) { place in
                    Annotation(place.title, coordinate: place.coordinate, anchor: .bottom) {
                        Button {
                            selectedPlace = place
                        } label: {
                            Image(systemName: place.category.symbol)
                                .font(.system(size: 15, weight: .bold))
                                .foregroundStyle(.white)
                                .frame(width: 36, height: 36)
                                .background(place.category.color, in: Circle())
                                .overlay(Circle().stroke(.white, lineWidth: 2.5))
                                .shadow(color: .black.opacity(0.28), radius: 4, y: 2)
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel("공간: \(place.title)")
                    }
                    .annotationTitles(.hidden)
                }
                ForEach(visibleReports) { report in
                    Annotation(report.title, coordinate: report.coordinate, anchor: .bottom) {
                        Button { selectedReport = report } label: {
                            Text(report.kind.emoji)
                                .font(.system(size: 20))
                                .frame(width: 37, height: 37)
                                .background(.white, in: Circle())
                                .overlay(Circle().stroke(report.kind.color, lineWidth: 2.5))
                                .shadow(color: .black.opacity(0.2), radius: 3)
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel("\(report.kind.rawValue): \(report.title)")
                    }
                    .annotationTitles(.hidden)
                }
            }
            .mapStyle(hybrid ? .hybrid(elevation: .flat) : .imagery(elevation: .flat))
            .mapControlVisibility(.hidden)
            .onMapCameraChange(frequency: .onEnd) { context in
                mapCenter = context.region.center
            }
            .ignoresSafeArea(edges: .top)

            // 화면 중앙의 십자선이 새 공간 등록 좌표를 나타냅니다.
            Image(systemName: "plus")
                .font(.system(size: 15, weight: .black))
                .foregroundStyle(AppTheme.crimson)
                .padding(11)
                .background(.regularMaterial, in: Circle())
                .overlay(Circle().stroke(AppTheme.crimson.opacity(0.75), lineWidth: 1.5))
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .allowsHitTesting(false)
                .accessibilityHidden(true)

            VStack(spacing: 12) {
                header
                categoryFilter
                reportTypeFilter
                Spacer()
                bottomPanel
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)
            .padding(.bottom, 10)
        }
        .sheet(item: $selectedPlace) { place in
            NavigationStack { PlaceDetailView(place: place) }
                .presentationDetents([.medium, .large])
        }
        .sheet(item: $selectedReport) { report in
            NavigationStack { SightingDetailView(report: report) }
                .presentationDetents([.medium, .large])
        }
        .sheet(item: $selectedBuilding) { building in
            NavigationStack { BuildingDetailView(building: building) }
                .presentationDetents([.medium])
        }
        .sheet(isPresented: $showingAdd) {
            NavigationStack { NewPlaceView(coordinate: mapCenter) }
        }
        .sheet(isPresented: $showingReportAdd) {
            NavigationStack { NewSightingView(coordinate: mapCenter) }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top, spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("KU DOT · 고려대학교 돗자리")
                        .font(.system(size: 10, weight: .black, design: .rounded))
                        .tracking(2.2)
                        .foregroundStyle(AppTheme.crimson)
                    Text("KU돗  쿠돗")
                        .font(.title2.bold())
                    Text("수업 사이, 돗자리 위, 혼자 걷는 캠퍼스")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer(minLength: 4)
                Image(systemName: "sun.horizon.circle.fill")
                    .font(.system(size: 34))
                    .foregroundStyle(AppTheme.green)
            }
            HStack(spacing: 8) {
                Label("위성 · 2D", systemImage: "globe.asia.australia.fill")
                    .font(.caption2.bold())
                    .foregroundStyle(.secondary)
                Spacer()
                Toggle("건물", isOn: $showBuildings)
                    .labelsHidden()
                    .tint(AppTheme.crimson)
                    .scaleEffect(0.80, anchor: .trailing)
                Text("건물 표시")
                    .font(.caption2)
                Button {
                    hybrid.toggle()
                } label: {
                    Label(hybrid ? "위성만" : "지도 글자", systemImage: "square.3.layers.3d")
                        .font(.caption2.bold())
                }
                .buttonStyle(.bordered)
                .tint(AppTheme.green)
            }
        }
        .padding(15)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 22))
        .shadow(color: .black.opacity(0.10), radius: 12, y: 5)
    }

    private var categoryFilter: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                filterButton("전체", symbol: "square.grid.2x2.fill", category: nil)
                ForEach(PlaceCategory.allCases) { category in
                    filterButton(category.rawValue, symbol: category.symbol, category: category)
                }
            }
        }
    }

    private var reportTypeFilter: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                reportChip("발견 전체", kind: nil)
                ForEach(FieldReportKind.allCases) { kind in
                    reportChip("\(kind.emoji) \(kind.rawValue)", kind: kind)
                }
                Button { showReports = false } label: {
                    Text("제보 숨기기")
                        .font(.caption.bold())
                        .padding(.horizontal, 12)
                        .padding(.vertical, 9)
                        .foregroundStyle(showReports ? AppTheme.green : .white)
                        .background(showReports ? Color.white.opacity(0.95) : AppTheme.crimson,
                                    in: Capsule())
                }
                .buttonStyle(.plain)
            }
        }
    }

    private func reportChip(_ label: String, kind: FieldReportKind?) -> some View {
        let active = showReports && reportFilter == kind
        return Button {
            showReports = true
            reportFilter = kind
        } label: {
            Text(label)
                .font(.caption.bold())
                .padding(.horizontal, 12)
                .padding(.vertical, 9)
                .foregroundStyle(active ? .white : AppTheme.crimson)
                .background(active ? AppTheme.crimson : Color.white.opacity(0.95), in: Capsule())
        }
        .buttonStyle(.plain)
    }

    private func filterButton(_ label: String, symbol: String,
                              category: PlaceCategory?) -> some View {
        let active = filter == category
        return Button {
            filter = category
        } label: {
            Label(label, systemImage: symbol)
                .font(.caption.bold())
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .foregroundStyle(active ? .white : AppTheme.green)
                .background(active ? AppTheme.green : Color.white.opacity(0.95),
                            in: Capsule())
        }
        .buttonStyle(.plain)
    }

    private var bottomPanel: some View {
        VStack(alignment: .leading, spacing: 11) {
            HStack {
                VStack(alignment: .leading, spacing: 3) {
                    Text("쉼터 \(visiblePlaces.count)곳 · 발견/주의 \(visibleReports.count)건")
                        .font(.subheadline.bold())
                    Text("마커를 누르면 자세히 볼 수 있어요")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Button {
                    cameraPosition = .region(
                        MKCoordinateRegion(center: CampusData.center,
                                           span: MKCoordinateSpan(latitudeDelta: 0.0055,
                                                                  longitudeDelta: 0.0065))
                    )
                } label: {
                    Image(systemName: "scope")
                        .font(.title3.bold())
                        .frame(width: 42, height: 42)
                }
                .buttonStyle(.bordered)
                .accessibilityLabel("이과캠퍼스로 이동")
            }

            HStack(spacing: 8) {
                Button { showingAdd = true } label: {
                    Label("쉼터 등록", systemImage: "leaf.fill")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                }
                .foregroundStyle(.white)
                .background(AppTheme.green, in: RoundedRectangle(cornerRadius: 14))

                Button { showingReportAdd = true } label: {
                    Label("발견 제보", systemImage: "pawprint.fill")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                }
                .foregroundStyle(.white)
                .background(AppTheme.crimson, in: RoundedRectangle(cornerRadius: 14))
            }
            .font(.subheadline.bold())
            .buttonStyle(.plain)
        }
        .padding(15)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 22))
        .shadow(color: .black.opacity(0.13), radius: 12, y: 4)
    }
}
