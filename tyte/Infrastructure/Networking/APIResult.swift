import Foundation

/// API 호출 결과를 처리하는 제네릭 타입을 정의하는 파일입니다.
/// 네트워크 요청의 성공/실패를 타입 안전하게 처리합니다.
///
/// ## 사용 예시
/// ```swift
/// let result = try APIResult<LoginResponse>(statusCode: 200, data: responseData)
/// switch result {
/// case .success(let response):
///     // 성공 처리
/// case .failure(let error):
///     // 에러 처리
/// }
/// ```
///
/// - Note: 모든 결과는 성공 또는 실패로 명확하게 구분됩니다.
/// - Todo: 제너릭 관련 정리 블로그 링크 업로드하기

enum APIResult<T: Decodable> {
    case success(T)
    case failure(Error)  // 일반적인 Error 프로토콜 사용
    
    init(statusCode: Int, data: Data) throws {
        let decoder = JSONDecoder()
        
        switch statusCode {
        case 200..<300:
            let response = try decoder.decode(T.self, from: data)
            self = .success(response)
        default:
            throw APIError.unknown
        }
    }
}
