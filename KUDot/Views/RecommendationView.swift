import SwiftUI

struct RecommendationView: View {
    @EnvironmentObject private var store: PlaceStore
    @State private var purpose: RestPurpose = .shortBreak
    @State private var avoidSmoking = true
    @State private var selectedPlace: PlaceRecord?
    @State private var showingAdd = false

    private var allMatches: [PlaceRecord] {
        store.places
            .filter { $0.relevance(to: purpose) > 0 }
            .sorted { a, b in
                let first = a.relevance(to: purpose)
                let second = b.relevance(to: purpose)
                if first != second { return first > second }
                return a.title < b.title
            }
    }

    private var recommendations: [PlaceRecord] {
        allMatches.filter { !avoidSmoking || !store.hasSmokingNotice(near: $0) }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 19) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("오늘은 어디서 쉴까?")
                            .font(.title2.bold())
                        Text("수업 사이의 10분부터 혼자 걷는 오후까지, 지금의 쉼에 맞는 공간을 골라봐요.")
                            .foregroundStyle(.secondary)
                            .font(.subheadline)
                    }
                    .padding(20)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(.white, in: RoundedRectangle(cornerRadius: 20))

                    Text("어떤 휴식이 필요한가요?")
                        .font(.headline)
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                        ForEach(RestPurpose.allCases) { item in
                            Button { purpose = item } label: {
                                VStack(alignment: .leading, spacing: 8) {
                                    Image(systemName: item.symbol)
                                        .font(.title2)
                                    Text(item.rawValue).font(.subheadline.bold())
                                    Text(item.subtitle)
                                        .font(.caption2)
                                        .multilineTextAlignment(.leading)
                                        .lineLimit(2)
                                }
                                .frame(maxWidth: .infinity, minHeight: 103, alignment: .leading)
                                .padding(13)
                                .foregroundStyle(purpose == item ? .white : AppTheme.green)
                                .background(purpose == item ? AppTheme.green : Color.white,
                                            in: RoundedRectangle(cornerRadius: 17))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    Toggle(isOn: $avoidSmoking) {
                        VStack(alignment: .leading, spacing: 3) {
                            Text("흡연 주의 장소 주변 제외")
                                .font(.subheadline.bold())
                            Text("이 기기에 기록된 최근 45일 이내 제보 지점 약 60m 이내")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .tint(AppTheme.green)
                    .padding(14)
                    .background(.white, in: RoundedRectangle(cornerRadius: 16))

                    HStack {
                        Text("\(purpose.rawValue) 추천 후보")
                            .font(.headline)
                        Spacer()
                        Text("\(recommendations.count)곳")
                            .font(.subheadline.bold())
                            .foregroundStyle(.secondary)
                    }

                    if recommendations.isEmpty {
                        ContentUnavailableView("추천 후보가 없어요", systemImage: "leaf.circle",
                                               description: Text("다른 휴식 목적을 골라보거나 직접 새로운 장소를 등록해 주세요."))
                        Button("새 공간 기록하기") { showingAdd = true }
                            .buttonStyle(.borderedProminent)
                    } else {
                        ForEach(recommendations) { place in
                            Button { selectedPlace = place } label: {
                                HStack(alignment: .top, spacing: 12) {
                                    Image(systemName: place.category.symbol)
                                        .font(.title2)
                                        .foregroundStyle(place.category.color)
                                        .frame(width: 46, height: 46)
                                        .background(place.category.color.opacity(0.12),
                                                    in: RoundedRectangle(cornerRadius: 12))
                                    VStack(alignment: .leading, spacing: 7) {
                                        Text(place.title).font(.headline)
                                        Text(place.relevance(to: purpose) == 2
                                             ? "등록된 활동 태그와 일치"
                                             : "공간 유형을 바탕으로 고른 탐색 후보")
                                            .font(.caption.bold())
                                            .foregroundStyle(place.category.color)
                                        Text(place.note)
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                            .lineLimit(2)
                                    }
                                    Spacer(minLength: 0)
                                    Image(systemName: "chevron.right")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                .padding(15)
                                .background(.white, in: RoundedRectangle(cornerRadius: 17))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    if avoidSmoking && recommendations.count < allMatches.count {
                        Label("흡연 주의 지점 근처 후보 \(allMatches.count - recommendations.count)곳을 숨겼어요.",
                              systemImage: "info.circle")
                            .font(.caption)
                            .foregroundStyle(AppTheme.crimson)
                    }
                    Text("추천은 새로 등록한 장소의 활동 태그와 공간 유형을 이용한 단순 분류예요. 실제 출입 제한, 돗자리 가능 여부와 흡연 상황은 현장에서 확인해 주세요.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .padding(.bottom, 16)
                }
                .padding(17)
            }
            .background(AppTheme.background)
            .navigationTitle("KU돗 추천")
            .sheet(item: $selectedPlace) { place in
                NavigationStack { PlaceDetailView(place: place) }
                    .presentationDetents([.medium, .large])
            }
            .sheet(isPresented: $showingAdd) {
                NavigationStack { NewPlaceView(coordinate: CampusData.center) }
            }
        }
    }
}
