import Foundation
import CoreLocation

/// 캠퍼스 건물의 중심점은 공개 OpenStreetMap 기반 자료를 참고한 초깃값입니다.
/// 정밀한 출입구 위치/건물 외곽선이 아니므로 운영 전에 현장 검증이 필요합니다.
enum CampusData {
    static let center = CLLocationCoordinate2D(latitude: 37.58410, longitude: 127.02660)

    static let buildings: [CampusBuilding] = [
        .init(id: "asan", name: "아산이학관", latitude: 37.58517, longitude: 127.02533),
        .init(id: "hana-b", name: "하나과학관 B동", latitude: 37.58572, longitude: 127.02470),
        .init(id: "medihill", name: "메디힐지구환경관", latitude: 37.58553, longitude: 127.02562),
        .init(id: "life-west", name: "생명과학관 서관", latitude: 37.58566, longitude: 127.02653),
        .init(id: "science-lib", name: "과학도서관", latitude: 37.58459, longitude: 127.02664),
        .init(id: "future", name: "미래융합기술관", latitude: 37.58478, longitude: 127.02820),
        .init(id: "woojung", name: "우정정보관", latitude: 37.58514, longitude: 127.02859),
        .init(id: "cafeteria", name: "자연계 생활관", latitude: 37.58443, longitude: 127.02744),
        .init(id: "engineering", name: "공학관", latitude: 37.58367, longitude: 127.02528),
        .init(id: "technocomplex", name: "산학관", latitude: 37.58417, longitude: 127.02447),
        .init(id: "experiment2", name: "제2실험관", latitude: 37.58322, longitude: 127.02545),
        .init(id: "new-engineering", name: "신공학관", latitude: 37.58250, longitude: 127.02639),
        .init(id: "student-center", name: "애기능학생회관", latitude: 37.58247, longitude: 127.02749),
        .init(id: "robot", name: "로봇융합관", latitude: 37.58182, longitude: 127.02645)
    ]
}
