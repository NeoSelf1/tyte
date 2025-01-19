import Foundation

// HTTP 메서드 열거형 정의
enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
    case patch = "PATCH"
}

/// URLSession을 사용하여 인증이 필요한 요청과 불필요한 네트워크 요청을 처리하는 클래스
class NetworkAPI {
    // URLSession 인스턴스 생성
    private let session = URLSession.shared
    
    /// 인증이 필요한 API 요청을 처리하는 메서드
    /// - Parameters:
    ///   - endpoint: API 엔드포인트
    ///   - method: HTTP 메서드
    ///   - parameters: 요청 파라미터
    /// - Returns: 디코딩된 응답 데이터
    func request<T: Decodable>(
        _ endpoint: APIEndpoint,
        method: HTTPMethod = .get,
        parameters: [String: Any]? = nil
    ) async throws -> T {
        // 게스트 모드 체크
        guard !AppState.shared.isGuestMode else {
            throw APIError.isGuestMode
        }
        
        // 네트워크 연결 상태 체크
        guard NetworkManager.shared.isConnected else {
            throw APIError.networkError
        }
        
        // 액세스 토큰 체크
        guard let token = KeychainManager.shared.getAccessToken() else {
            throw APIError.unauthorized
        }
        
        // URL 생성
        guard let url = URL(string: APIConstants.baseUrl + endpoint.path) else {
            throw APIError.invalidURL
        }
        
        // URLRequest 생성
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // 파라미터가 있는 경우 요청 바디에 추가
        if let parameters = parameters {
            let jsonData = try JSONSerialization.data(withJSONObject: parameters)
            request.httpBody = jsonData
        }
        
        do {
            // 네트워크 요청 실행
            let (data, response) = try await session.data(for: request)
            
            // HTTP 응답 상태 코드 체크
            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.notFound
            }
            
            // 성공적인 응답인지 확인 (200-299 상태 코드)
            guard (200...299).contains(httpResponse.statusCode) else {
                throw APIError.serverError(String(httpResponse.statusCode))
            }
            
            // 응답 데이터 디코딩
            let decoder = JSONDecoder()
            return try decoder.decode(T.self, from: data)
        } catch {
            // 에러 처리
            throw APIError(error: error)
        }
    }
    
    /// 인증이 필요없는 API 요청을 처리하는 메서드
    func requestWithoutAuth<T: Decodable>(
        _ endpoint: APIEndpoint,
        method: HTTPMethod = .get,
        parameters: [String: Any]? = nil
    ) async throws -> T {
        // 네트워크 연결 상태 체크
        guard NetworkManager.shared.isConnected else {
            throw APIError.networkError
        }
        
        // URL 생성
        guard let url = URL(string: APIConstants.baseUrl + endpoint.path) else {
            throw APIError.invalidURL
        }
        
        // URLRequest 생성
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // 파라미터가 있는 경우 요청 바디에 추가
        if let parameters = parameters {
            let jsonData = try JSONSerialization.data(withJSONObject: parameters)
            request.httpBody = jsonData
        }
        
        do {
            // 네트워크 요청 실행
            let (data, response) = try await session.data(for: request)
            
            // HTTP 응답 상태 코드 체크
            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.notFound
            }
            
            // 성공적인 응답인지 확인 (200-299 상태 코드)
            guard (200...299).contains(httpResponse.statusCode) else {
                throw APIError.serverError(String(httpResponse.statusCode))
            }
            
            // 응답 데이터 디코딩
            let decoder = JSONDecoder()
            return try decoder.decode(T.self, from: data)
        } catch {
            // 에러 처리
            throw APIError(error: error)
        }
    }
    
    /// 에러 처리를 담당하는 private 메서드
    private func handleError(_ error: APIError) {
        DispatchQueue.main.async {
            switch error {
            case .unauthorized:
                // 인증 에러 시 로그아웃 처리
                UserDefaultsManager.shared.logout()
            case .networkError:
                // 네트워크 에러 로깅
                print("network error")
            default:
                // 기타 에러 토스트 메시지 표시
                ToastManager.shared.show(.error(error.localizedDescription))
            }
        }
    }
}

