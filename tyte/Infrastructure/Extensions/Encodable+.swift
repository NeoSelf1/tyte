import Foundation

/// Encodable 타입을 Dictionary로 변환하는 확장
///
/// JSON 인코딩을 통해 Encodable 타입의 인스턴스를
/// [String: Any] 형태의 딕셔너리로 변환합니다.
///
/// - Returns: 변환된 딕셔너리. 변환 실패 시 nil 반환
///
/// - Note: API 요청의 파라미터 구성 시 주로 사용됩니다.
extension Encodable {
    var dictionary: [String: Any]? {
        guard let data = try? JSONEncoder().encode(self) else { return nil }
        return (try? JSONSerialization.jsonObject(with: data, options: .allowFragments)).flatMap { $0 as? [String: Any] }
    }
}
