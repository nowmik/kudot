import SwiftUI

struct ArchiveView: View {
    @EnvironmentObject private var store: PlaceStore
    @State private var search = ""
    @State private var filter: PlaceCategory?
    @State private var selectedPlace: PlaceRecord?
    @State private var showingAdd = false

    private var filtered: [PlaceRecord] {
        store.places
            .filter { filter == nil || $0.category == filter }
            .filter {
                search.isEmpty ||
                $0.title.localizedCaseInsensitiveContains(search) ||
                $0.note.localizedCaseInsensitiveContains(search)
            }
            .sorted { $0.createdAt > $1.createdAt }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    introduction
                    HStack {
                        Text("모든 공간")
                            .font(.title3.bold())
                        Spacer()
                        Text("\(filtered.count)곳")
                            .font(.subheadline.bold())
                            .foregroundStyle(.secondary)
                    }
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            chip("전체", category: nil)
                            ForEach(PlaceCategory.allCases) { category in
                                chip(category.rawValue, category: category)
                            }
                        }
                    }

                    if filtered.isEmpty {
                        if store.places.isEmpty {
                            ContentUnavailableView(
                                "첫 쉼터를 등록해 주세요",
                                systemImage: "leaf.circle",
                                description: Text("아직 등록된 장소가 없어요. 지도에서 돗자리를 펼 수 있는 곳이나 산책하기 좋은 길을 찾아 기록해 보세요.")
                            )
                            Button("새 공간 등록하기") { showingAdd = true }
                                .buttonStyle(.borderedProminent)
                        } else {
                            ContentUnavailableView.search(text: search)
                        }
                    } else {
                        LazyVStack(spacing: 11) {
                            ForEach(filtered) { place in
                                Button {
                                    selectedPlace = place
                                } label: {
                                    PlaceRow(place: place)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }
                .padding(18)
            }
            .background(AppTheme.background)
            .navigationTitle("KU돗 쉼터 모음")
            .searchable(text: $search, prompt: "공간 이름이나 기록 검색")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingAdd = true
                    } label: {
                        Label("공간 추가", systemImage: "plus")
                    }
                }
            }
            .sheet(item: $selectedPlace) { place in
                NavigationStack { PlaceDetailView(place: place) }
                    .presentationDetents([.medium, .large])
            }
            .sheet(isPresented: $showingAdd) {
                NavigationStack { NewPlaceView(coordinate: CampusData.center) }
            }
        }
    }

    private var introduction: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: "leaf.fill")
                    .foregroundStyle(AppTheme.green)
                Text("KU돗, 우리의 캠퍼스 쉼표")
                    .font(.headline)
            }
            Text("고대의 녹지와 휴식 공간을 모아요. 사진과 기록은 현재 이 기기에만 저장돼요.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
            HStack(spacing: 16) {
                Label("전체 \(store.places.count)", systemImage: "mappin.and.ellipse")
                Label("이 기기의 기록", systemImage: "iphone")
            }
            .font(.caption.bold())
            .foregroundStyle(AppTheme.green)
            .padding(.top, 4)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(.white, in: RoundedRectangle(cornerRadius: 20))
    }

    private func chip(_ text: String, category: PlaceCategory?) -> some View {
        let active = filter == category
        return Button {
            filter = category
        } label: {
            Text(text)
                .font(.caption.bold())
                .foregroundStyle(active ? .white : .primary)
                .padding(.horizontal, 15)
                .padding(.vertical, 10)
                .background(active ? AppTheme.green : .white, in: Capsule())
        }
        .buttonStyle(.plain)
    }
}

struct PlaceRow: View {
    @EnvironmentObject private var store: PlaceStore
    let place: PlaceRecord

    var body: some View {
        HStack(spacing: 13) {
            ZStack {
                RoundedRectangle(cornerRadius: 13)
                    .fill(place.category.color.opacity(0.11))
                if let image = store.image(for: place) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 74, height: 74)
                        .clipped()
                        .clipShape(RoundedRectangle(cornerRadius: 13))
                } else {
                    Image(systemName: place.category.symbol)
                        .font(.system(size: 27))
                        .foregroundStyle(place.category.color)
                }
            }
            .frame(width: 74, height: 74)

            VStack(alignment: .leading, spacing: 5) {
                Text(place.title)
                    .font(.subheadline.bold())
                    .foregroundStyle(.primary)
                Text(place.note)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
                Text("\(place.category.rawValue) · 내가 등록한 공간")
                    .font(.caption2.bold())
                    .foregroundStyle(place.category.color)
            }
            Spacer(minLength: 0)
            Image(systemName: "chevron.right")
                .font(.caption.bold())
                .foregroundStyle(.tertiary)
        }
        .padding(13)
        .background(.white, in: RoundedRectangle(cornerRadius: 18))
    }
}
