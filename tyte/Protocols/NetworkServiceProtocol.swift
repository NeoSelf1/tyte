import Combine
import Alamofire

/// 네트워크 서비스 계층의 프로토콜 정의 모음입니다.
/// 프로토콜 기반 설계를 통해 다음과 같은 이점을 제공합니다:
/// - 의존성 역전 원칙(DIP) 구현
/// - 테스트 용이성 향상
/// - 구현 세부사항과 인터페이스 분리
/// - Mock 객체 생성 간소화

/// 기본 네트워크 요청 처리를 위한 프로토콜입니다.
/// 인증이 필요한 요청과 불필요한 요청을 구분하여 처리합니다.
protocol NetworkServiceProtocol {
    /// 인증이 필요한 API 요청을 처리합니다.
    /// - Parameters:
    ///   - endpoint: API 엔드포인트
    ///   - method: HTTP 메서드
    ///   - parameters: 요청 파라미터
    /// - Returns: 디코딩된 응답 데이터를 포함하는 Publisher
    
    func request<T: Decodable>(
        _ endpoint: APIEndpoint,
        method: HTTPMethod,
        parameters: Parameters?
    ) -> AnyPublisher<T, APIError>
    
    /// 인증이 필요없는 API 요청을 처리합니다.
    /// - Parameters:
    ///   - endpoint: API 엔드포인트
    ///   - method: HTTP 메서드
    ///   - parameters: 요청 파라미터
    /// - Returns: 디코딩된 응답 데이터를 포함하는 Publisher
    func requestWithoutAuth<T: Decodable>(
        _ endpoint: APIEndpoint,
        method: HTTPMethod,
        parameters: Parameters?
    ) -> AnyPublisher<T, APIError>
}
