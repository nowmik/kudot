import SwiftUI
import PhotosUI
import CoreLocation

/// 학교 내 동물 목격과 흡연 주의 정보를 모으는 로컬 아카이브.
struct SightingView: View {
    @EnvironmentObject private var store: PlaceStore
    @State private var filter: FieldReportKind?
    @State private var selectedReport: FieldReport?
    @State private var showingAdd = false

    private var filtered: [FieldReport] {
        store.reports
            .filter { filter == nil || $0.kind == filter }
            .sorted { $0.createdAt > $1.createdAt }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    VStack(alignment: .leading, spacing: 9) {
                        Text("캠퍼스의 작은 발견들")
                            .font(.title2.bold())
                        Text("고양이를 만났거나 청설모를 보았나요? 또는 쉬는 길에 피하고 싶은 흡연 장소가 있었나요? 현장 경험을 기록해요.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        Text("목격 기록은 실시간 위치가 아니며, 이용자 제보는 공식적으로 검증되지 않았어요.")
                            .font(.caption)
                            .foregroundStyle(AppTheme.crimson)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(19)
                    .background(.white, in: RoundedRectangle(cornerRadius: 20))

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            filterChip("전체", kind: nil)
                            ForEach(FieldReportKind.allCases) { kind in
                                filterChip("\(kind.emoji) \(kind.rawValue)", kind: kind)
                            }
                        }
                    }

                    Text("발견 기록 \(filtered.count)개")
                        .font(.headline)
                    if filtered.isEmpty {
                        ContentUnavailableView("아직 기록이 없어요", systemImage: "pawprint",
                                               description: Text("지도에서 만난 생명과 장소를 먼저 기록해 주세요."))
                    } else {
                        LazyVStack(spacing: 10) {
                            ForEach(filtered) { report in
                                Button { selectedReport = report } label: {
                                    HStack(spacing: 12) {
                                        Text(report.kind.emoji).font(.system(size: 30))
                                            .frame(width: 58, height: 58)
                                            .background(report.kind.color.opacity(0.12),
                                                        in: RoundedRectangle(cornerRadius: 14))
                                        VStack(alignment: .leading, spacing: 5) {
                                            Text(report.title).font(.subheadline.bold())
                                            Text("직접 작성한 제보 · 현장 확인 전")
                                                .font(.caption2)
                                                .foregroundStyle(report.kind.color)
                                            Text(report.createdAt, format: .dateTime.year().month().day())
                                                .font(.caption)
                                                .foregroundStyle(.secondary)
                                        }
                                        Spacer(minLength: 0)
                                        Image(systemName: "chevron.right")
                                            .font(.caption.bold())
                                            .foregroundStyle(.tertiary)
                                    }
                                    .padding(13)
                                    .background(.white, in: RoundedRectangle(cornerRadius: 17))
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }
                .padding(17)
            }
            .background(AppTheme.background)
            .navigationTitle("발견과 주의")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { showingAdd = true } label: {
                        Label("목격 제보 추가", systemImage: "plus")
                    }
                }
            }
            .sheet(item: $selectedReport) { report in
                NavigationStack { SightingDetailView(report: report) }
                    .presentationDetents([.medium, .large])
            }
            .sheet(isPresented: $showingAdd) {
                NavigationStack { NewSightingView(coordinate: CampusData.center) }
            }
        }
    }

    private func filterChip(_ label: String, kind: FieldReportKind?) -> some View {
        Button { filter = kind } label: {
            Text(label)
                .font(.caption.bold())
                .padding(.horizontal, 13)
                .padding(.vertical, 10)
                .foregroundStyle(filter == kind ? .white : AppTheme.green)
                .background(filter == kind ? AppTheme.green : .white, in: Capsule())
        }
        .buttonStyle(.plain)
    }
}

struct NewSightingView: View {
    @EnvironmentObject private var store: PlaceStore
    @Environment(\.dismiss) private var dismiss

    @State private var kind: FieldReportKind = .cat
    @State private var note = ""
    @State private var latitudeText: String
    @State private var longitudeText: String
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var photoData: Data?
    @State private var photoError = false

    init(coordinate: CLLocationCoordinate2D) {
        _latitudeText = State(initialValue: String(format: "%.6f", coordinate.latitude))
        _longitudeText = State(initialValue: String(format: "%.6f", coordinate.longitude))
    }

    private var latitude: Double? { Double(latitudeText.trimmingCharacters(in: .whitespaces)) }
    private var longitude: Double? { Double(longitudeText.trimmingCharacters(in: .whitespaces)) }
    private var canSave: Bool {
        latitude.map { (37.5800...37.5880).contains($0) } == true &&
        longitude.map { (127.0210...127.0320).contains($0) } == true
    }

    var body: some View {
        Form {
            Section("어떤 것을 발견했나요?") {
                Picker("종류", selection: $kind) {
                    ForEach(FieldReportKind.allCases) { item in
                        Text("\(item.emoji) \(item.rawValue)").tag(item)
                    }
                }
                VStack(alignment: .leading, spacing: 6) {
                    Text(kind == .smoking ? "흡연 관련 상황 (선택)" : "목격 상황 (선택)")
                        .font(.subheadline.bold())
                    TextEditor(text: $note)
                        .frame(minHeight: 100)
                }
            }
            Section("사진 (선택)") {
                PhotosPicker(selection: $selectedPhoto, matching: .images) {
                    Label(photoData == nil ? "사진 첨부" : "사진 다시 선택", systemImage: "photo")
                }
                if let data = photoData, let image = UIImage(data: data) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 190)
                }
            }
            Section {
                TextField("위도", text: $latitudeText).keyboardType(.decimalPad)
                TextField("경도", text: $longitudeText).keyboardType(.decimalPad)
            } header: {
                Text("발견한 위치")
            } footer: {
                Text("지도 중앙의 위치로 시작합니다. 좌표를 수정해 실제 발견 지점을 입력하세요. 이과캠퍼스 주변만 등록할 수 있습니다.")
            }
            Section {
                Label(kind == .smoking
                      ? "흡연 주의 제보는 공식 지정 구역으로 표시되지 않으며, 현장 상황과 다를 수 있어요."
                      : "동물을 쫓거나 먹이를 주지 않고, 안전한 거리에서 관찰해 주세요.",
                      systemImage: "info.circle")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            Button { save() } label: {
                Label("발견 기록 저장", systemImage: "checkmark.circle.fill")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
            }
            .disabled(!canSave)
        }
        .navigationTitle("새로운 발견")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) { Button("취소") { dismiss() } }
        }
        .onChange(of: selectedPhoto) { _, item in
            Task {
                do { photoData = try await item?.loadTransferable(type: Data.self) }
                catch { photoError = true }
            }
        }
        .alert("사진을 불러오지 못했어요", isPresented: $photoError) {
            Button("확인", role: .cancel) { }
        }
    }

    private func save() {
        guard canSave, let latitude, let longitude else { return }
        store.addReport(kind: kind, note: note.trimmingCharacters(in: .whitespacesAndNewlines),
                        latitude: latitude, longitude: longitude, photoData: photoData)
        dismiss()
    }
}

struct SightingDetailView: View {
    @EnvironmentObject private var store: PlaceStore
    @Environment(\.dismiss) private var dismiss
    @State private var confirmingDelete = false
    let report: FieldReport

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                HStack(spacing: 12) {
                    Text(report.kind.emoji).font(.system(size: 45))
                    VStack(alignment: .leading, spacing: 5) {
                        Text(report.title).font(.title2.bold())
                        Text("직접 작성한 제보 · 확인되지 않음")
                            .font(.caption.bold())
                            .foregroundStyle(report.kind.color)
                    }
                }
                if let image = store.image(for: report) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity)
                        .clipShape(RoundedRectangle(cornerRadius: 15))
                }
                Text(report.createdAt, format: .dateTime.year().month().day().hour().minute())
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(report.note.isEmpty ? "추가 메모가 없습니다." : report.note)
                    .font(.body)
                Text("목격 또는 제보 당시의 기록이에요. 지금도 같은 상태인지는 알 수 없어요.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                HStack(spacing: 9) {
                    ShareLink(item: report.shareText) {
                        Label("공유", systemImage: "square.and.arrow.up")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    Link(destination: report.mapsURL) {
                        Label("지도", systemImage: "map")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                }
                Button(role: .destructive) { confirmingDelete = true } label: {
                    Label("이 기록 삭제", systemImage: "trash")
                }
            }
            .padding(20)
        }
        .navigationTitle("발견 상세")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) { Button("닫기") { dismiss() } }
        }
        .confirmationDialog("기록과 사진을 삭제할까요?", isPresented: $confirmingDelete) {
            Button("삭제", role: .destructive) { store.delete(report); dismiss() }
        }
    }
}
