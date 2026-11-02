import Foundation
import CoreLocation
import UIKit

/// 새 기록만 이 기기에 저장하는 로컬 MVP. 이전 앱 기록을 가져오지 않습니다.
@MainActor
final class PlaceStore: ObservableObject {
    @Published private(set) var places: [PlaceRecord] = []
    @Published private(set) var reports: [FieldReport] = []

    private let directory: URL
    private let placesURL: URL
    private let reportsURL: URL

    init() {
        let support = FileManager.default.urls(for: .applicationSupportDirectory,
                                               in: .userDomainMask)[0]
        // 독립적인 저장 공간: 최초 실행 시 번들에 과거 기록이나 예시 기록이 없습니다.
        directory = support.appendingPathComponent("KUDot", isDirectory: true)
        placesURL = directory.appendingPathComponent("places.json")
        reportsURL = directory.appendingPathComponent("reports.json")
        try? FileManager.default.createDirectory(at: directory,
                                                 withIntermediateDirectories: true)

        if let data = try? Data(contentsOf: placesURL),
           let saved = try? JSONDecoder().decode([PlaceRecord].self, from: data) {
            places = saved
        } else {
            places = []
        }

        if let data = try? Data(contentsOf: reportsURL),
           let saved = try? JSONDecoder().decode([FieldReport].self, from: data) {
            reports = saved
        } else {
            reports = []
        }
    }

    func add(title: String, category: PlaceCategory, note: String,
             latitude: Double, longitude: Double, photoData: Data?,
             purposes: [RestPurpose] = []) {
        let id = UUID()
        places.insert(PlaceRecord(id: id, title: title, category: category,
                                  note: note, latitude: latitude, longitude: longitude,
                                  photoFileName: savePhoto(photoData, id: id),
                                  createdAt: .now, purposes: purposes), at: 0)
        savePlaces()
    }

    func delete(_ place: PlaceRecord) {
        deletePhoto(place.photoFileName)
        places.removeAll { $0.id == place.id }
        savePlaces()
    }

    func addReport(kind: FieldReportKind, note: String, latitude: Double,
                   longitude: Double, photoData: Data?) {
        let id = UUID()
        reports.insert(FieldReport(id: id, kind: kind,
                                   title: kind.rawValue, note: note,
                                   latitude: latitude, longitude: longitude,
                                   createdAt: .now, photoFileName: savePhoto(photoData, id: id)), at: 0)
        saveReports()
    }

    func delete(_ report: FieldReport) {
        deletePhoto(report.photoFileName)
        reports.removeAll { $0.id == report.id }
        saveReports()
    }

    func image(for place: PlaceRecord) -> UIImage? { loadPhoto(place.photoFileName) }
    func image(for report: FieldReport) -> UIImage? { loadPhoto(report.photoFileName) }

    /// 단순한 거리 근접 경고입니다. 연기의 실제 이동/흡연구역의 경계를 판정하지 않습니다.
    func hasSmokingNotice(near place: PlaceRecord, radius: Double = 60) -> Bool {
        let point = CLLocation(latitude: place.latitude, longitude: place.longitude)
        return reports.contains { report in
            guard report.kind == .smoking, report.isRecent else { return false }
            let alertPoint = CLLocation(latitude: report.latitude, longitude: report.longitude)
            return point.distance(from: alertPoint) < radius
        }
    }

    private func savePhoto(_ data: Data?, id: UUID) -> String? {
        guard let data, let image = UIImage(data: data),
              let jpeg = image.jpegData(compressionQuality: 0.78) else { return nil }
        let filename = "\(id.uuidString).jpg"
        let url = directory.appendingPathComponent(filename)
        guard (try? jpeg.write(to: url, options: .atomic)) != nil else { return nil }
        return filename
    }

    private func loadPhoto(_ filename: String?) -> UIImage? {
        guard let filename else { return nil }
        return UIImage(contentsOfFile: directory.appendingPathComponent(filename).path)
    }

    private func deletePhoto(_ filename: String?) {
        guard let filename else { return }
        try? FileManager.default.removeItem(at: directory.appendingPathComponent(filename))
    }

    private func savePlaces() {
        guard let data = try? JSONEncoder().encode(places) else { return }
        try? data.write(to: placesURL, options: .atomic)
    }

    private func saveReports() {
        guard let data = try? JSONEncoder().encode(reports) else { return }
        try? data.write(to: reportsURL, options: .atomic)
    }
}
