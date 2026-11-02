import SwiftUI

struct PlaceDetailView: View {
    @EnvironmentObject private var store: PlaceStore
    @Environment(\.dismiss) private var dismiss
    @State private var confirmingDelete = false
    let place: PlaceRecord

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                photoHeader

                HStack(spacing: 8) {
                    Label(place.category.rawValue, systemImage: place.category.symbol)
                        .foregroundStyle(place.category.color)
                        .font(.subheadline.bold())
                }
                Text(place.title)
                    .font(.largeTitle.bold())
                    .foregroundStyle(.primary)

                Text(place.note)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)

                if !place.selectedPurposes.isEmpty {
                    VStack(alignment: .leading, spacing: 7) {
                        Text("가능하다고 기록된 휴식")
                            .font(.subheadline.bold())
                        ForEach(place.selectedPurposes) { activity in
                            Label(activity.rawValue, systemImage: activity.symbol)
                                .font(.subheadline)
                                .foregroundStyle(AppTheme.green)
                        }
                    }
                }

                if store.hasSmokingNotice(near: place) {
                    Label("약 60m 이내 흡연 주의 정보가 있어요. 현장 상황을 확인하세요.",
                          systemImage: "exclamationmark.shield.fill")
                        .font(.footnote.bold())
                        .foregroundStyle(AppTheme.crimson)
                }

                HStack {
                    Image(systemName: "mappin.circle.fill")
                        .foregroundStyle(AppTheme.green)
                    Text(String(format: "위도 %.5f · 경도 %.5f",
                                place.latitude, place.longitude))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                HStack(spacing: 10) {
                    ShareLink(item: place.shareText) {
                        Label("공유하기", systemImage: "square.and.arrow.up")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)

                    Link(destination: place.mapsURL) {
                        Label("지도에서 열기", systemImage: "map")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                }
                .controlSize(.large)

                Button(role: .destructive) {
                    confirmingDelete = true
                } label: {
                    Label("이 기록 삭제", systemImage: "trash")
                }
                .padding(.top, 6)
            }
            .padding(20)
        }
        .navigationTitle("공간 상세")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("닫기") { dismiss() }
            }
        }
        .confirmationDialog("이 기록을 삭제할까요?", isPresented: $confirmingDelete) {
            Button("삭제", role: .destructive) {
                store.delete(place)
                dismiss()
            }
        } message: {
            Text("저장된 사진도 함께 삭제됩니다.")
        }
    }

    private var photoHeader: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(place.category.color.opacity(0.12))
            if let image = store.image(for: place) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: .infinity)
                    .frame(height: 185)
                    .clipped()
                    .clipShape(RoundedRectangle(cornerRadius: 20))
            } else {
                VStack(spacing: 8) {
                    Image(systemName: place.category.symbol)
                        .font(.system(size: 54))
                    Text("아직 등록된 사진이 없어요")
                        .font(.caption)
                }
                .foregroundStyle(place.category.color)
            }
        }
        .frame(height: 185)
    }
}

struct BuildingDetailView: View {
    @Environment(\.dismiss) private var dismiss
    let building: CampusBuilding

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            Label("건물 위치", systemImage: "building.2.fill")
                .foregroundStyle(AppTheme.crimson)
                .font(.subheadline.bold())
            Text(building.name)
                .font(.largeTitle.bold())
            Text("고려대학교 자연계캠퍼스")
                .foregroundStyle(.secondary)
            Text("지도에 표시된 위치는 건물 중심점의 참고 좌표입니다. 실제 출입구 위치와 다를 수 있습니다.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Link(destination: building.mapsURL) {
                Label("Apple 지도에서 보기", systemImage: "map.fill")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            Spacer()
        }
        .padding(22)
        .navigationTitle("건물 안내")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("닫기") { dismiss() }
            }
        }
    }
}
