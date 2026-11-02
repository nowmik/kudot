import Foundation
import CoreLocation
import SwiftUI

struct CampusBuilding: Identifiable, Hashable {
    let id: String
    let name: String
    let latitude: Double
    let longitude: Double

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    var mapsURL: URL {
        URL(string: "https://maps.apple.com/?ll=\(latitude),\(longitude)")!
    }
}

enum PlaceCategory: String, CaseIterable, Codable, Identifiable {
    case green = "녹지"
    case rest = "쉼터"
    case plaza = "광장"
    case indoor = "실내 휴게"

    var id: String { rawValue }

    var symbol: String {
        switch self {
        case .green: "leaf.fill"
        case .rest: "cup.and.saucer.fill"
        case .plaza: "figure.walk"
        case .indoor: "sofa.fill"
        }
    }

    var color: Color {
        switch self {
        case .green: Color(red: 0.16, green: 0.49, blue: 0.32)
        case .rest: Color(red: 0.16, green: 0.45, blue: 0.63)
        case .plaza: Color(red: 0.73, green: 0.41, blue: 0.16)
        case .indoor: Color(red: 0.45, green: 0.34, blue: 0.63)
        }
    }
}

/// 사용자가 직접 선택한 활동 태그와 유형만을 기반으로 추천합니다.
/// 사용자가 직접 등록한 장소에 휴식 태그가 없으면 유형 기반 탐색 후보로만 표시합니다.
enum RestPurpose: String, CaseIterable, Codable, Identifiable {
    case picnic = "돗자리 피크닉"
    case shortBreak = "수업 사이 쉼"
    case soloWalk = "혼자 산책"
    case nature = "자연 관찰"

    var id: String { rawValue }

    var symbol: String {
        switch self {
        case .picnic: "sun.max.fill"
        case .shortBreak: "cup.and.saucer.fill"
        case .soloWalk: "figure.walk"
        case .nature: "leaf.fill"
        }
    }

    var subtitle: String {
        switch self {
        case .picnic: "돗자리를 펴고 느긋하게"
        case .shortBreak: "다음 수업 전 잠깐"
        case .soloWalk: "조용히 걸으며 리프레시"
        case .nature: "풀과 나무를 바라보며"
        }
    }
}

struct PlaceRecord: Identifiable, Codable, Hashable {
    var id: UUID
    var title: String
    var category: PlaceCategory
    var note: String
    var latitude: Double
    var longitude: Double
    var photoFileName: String?
    var createdAt: Date
    var purposes: [RestPurpose]? = nil

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    var mapsURL: URL {
        URL(string: "https://maps.apple.com/?ll=\(latitude),\(longitude)")!
    }

    var shareText: String {
        "KU돗 · \(title)\n\(category.rawValue)\n\(note)\n\(mapsURL.absoluteString)"
    }

    var selectedPurposes: [RestPurpose] { purposes ?? [] }

    /// 공간 유형을 이용해 추린 방문 후보. 실제 돗자리 설치 가능 여부는 확인되지 않았습니다.
    var candidatePurposes: [RestPurpose] {
        switch category {
        case .green: [.picnic, .soloWalk, .nature]
        case .rest: [.shortBreak]
        case .plaza: [.shortBreak, .soloWalk]
        case .indoor: [.shortBreak]
        }
    }

    func relevance(to purpose: RestPurpose) -> Int {
        if selectedPurposes.contains(purpose) { return 2 }
        if candidatePurposes.contains(purpose) { return 1 }
        return 0
    }
}

enum FieldReportKind: String, CaseIterable, Codable, Identifiable {
    case cat = "고양이 목격"
    case squirrel = "청설모 목격"
    case smoking = "흡연 주의"

    var id: String { rawValue }

    var emoji: String {
        switch self {
        case .cat: "🐈"
        case .squirrel: "🐿️"
        case .smoking: "🚭"
        }
    }

    var symbol: String {
        switch self {
        case .cat: "cat.fill"
        case .squirrel: "pawprint.fill"
        case .smoking: "exclamationmark.shield.fill"
        }
    }

    var color: Color {
        switch self {
        case .cat: Color(red: 0.92, green: 0.48, blue: 0.24)
        case .squirrel: Color(red: 0.60, green: 0.38, blue: 0.18)
        case .smoking: Color(red: 0.72, green: 0.19, blue: 0.26)
        }
    }
}

struct FieldReport: Identifiable, Codable, Hashable {
    var id: UUID
    var kind: FieldReportKind
    var title: String
    var note: String
    var latitude: Double
    var longitude: Double
    var createdAt: Date
    var photoFileName: String?

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    var mapsURL: URL {
        URL(string: "https://maps.apple.com/?ll=\(latitude),\(longitude)")!
    }

    var shareText: String {
        "KU돗 · \(title)\n\(kind.rawValue)\n\(note)\n\(mapsURL.absoluteString)"
    }

    /// 동물 목격과 일반 흡연 제보는 실시간 정보가 아닙니다.
    var isRecent: Bool {
        Date().timeIntervalSince(createdAt) <= 45 * 24 * 60 * 60
    }
}
