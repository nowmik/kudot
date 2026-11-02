import SwiftUI
import PhotosUI
import CoreLocation

struct NewPlaceView: View {
    @EnvironmentObject private var store: PlaceStore
    @Environment(\.dismiss) private var dismiss

    @State private var title = ""
    @State private var category: PlaceCategory = .green
    @State private var note = ""
    @State private var purposes: Set<RestPurpose> = []
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
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        latitude.map { (37.5800...37.5880).contains($0) } == true &&
        longitude.map { (127.0210...127.0320).contains($0) } == true
    }

    var body: some View {
        Form {
            Section("공간 정보") {
                TextField("공간 이름 (예: 도서관 옆 작은 정원)", text: $title)
                    .textInputAutocapitalization(.never)
                Picker("공간 유형", selection: $category) {
                    ForEach(PlaceCategory.allCases) { item in
                        Label(item.rawValue, systemImage: item.symbol).tag(item)
                    }
                }
                VStack(alignment: .leading, spacing: 8) {
                    Text("이 공간의 특징 · 이용 후기")
                        .font(.subheadline)
                    TextEditor(text: $note)
                        .frame(minHeight: 100)
                }
            }

            Section {
                ForEach(RestPurpose.allCases) { activity in
                    Toggle(isOn: Binding(
                        get: { purposes.contains(activity) },
                        set: { selected in
                            if selected { purposes.insert(activity) }
                            else { purposes.remove(activity) }
                        }
                    )) {
                        Label(activity.rawValue, systemImage: activity.symbol)
                    }
                    .tint(AppTheme.green)
                }
            } header: {
                Text("이 공간에서 할 수 있는 휴식 (선택)")
            } footer: {
                Text("직접 확인한 활동만 선택해 주세요. 돗자리 사용은 학교의 현장 이용 안내를 우선합니다.")
            }

            Section("사진 (선택)") {
                PhotosPicker(selection: $selectedPhoto, matching: .images) {
                    Label(photoData == nil ? "앨범에서 사진 선택" : "다른 사진 선택",
                          systemImage: "photo.on.rectangle.angled")
                }
                if let data = photoData, let image = UIImage(data: data) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 210)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }

            Section {
                TextField("위도", text: $latitudeText)
                    .keyboardType(.decimalPad)
                TextField("경도", text: $longitudeText)
                    .keyboardType(.decimalPad)
            } header: {
                Text("지도 좌표")
            } footer: {
                Text("지도의 중심 좌표가 자동 입력됩니다. 위치가 정확하지 않으면 숫자를 수정하세요. 현재는 이과캠퍼스 인근만 등록할 수 있어요.")
            }

            Section {
                Button {
                    save()
                } label: {
                    Label("공간 기록 저장", systemImage: "checkmark.circle.fill")
                        .frame(maxWidth: .infinity)
                        .font(.headline)
                }
                .disabled(!canSave)
            }
        }
        .navigationTitle("KU돗 쉼터 등록")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("취소") { dismiss() }
            }
        }
        .onChange(of: selectedPhoto) { _, newItem in
            Task {
                do {
                    photoData = try await newItem?.loadTransferable(type: Data.self)
                } catch {
                    photoError = true
                }
            }
        }
        .alert("사진을 불러오지 못했어요", isPresented: $photoError) {
            Button("확인", role: .cancel) { }
        }
    }

    private func save() {
        guard canSave, let latitude, let longitude else { return }
        store.add(title: title.trimmingCharacters(in: .whitespacesAndNewlines),
                  category: category,
                  note: note.trimmingCharacters(in: .whitespacesAndNewlines),
                  latitude: latitude, longitude: longitude,
                  photoData: photoData, purposes: RestPurpose.allCases.filter { purposes.contains($0) })
        dismiss()
    }
}
