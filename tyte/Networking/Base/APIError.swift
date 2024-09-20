import Foundation
import Alamofire

enum APIError: Error {
    case invalidURL
    case invalidTodo
    case noData
    case decodingError
    case networkError(String)
    case serverError(String)
    case unauthorized
    case notFound
    case unknown

    init(afError: AFError) {
        switch afError {
        case .invalidURL(let url):
            self = .invalidURL
            print("Invalid URL: \(url)")
        case .responseSerializationFailed(reason: .decodingFailed(_)):
            self = .decodingError
        case .responseValidationFailed(reason: .unacceptableStatusCode(let code)):
            switch code {
            case 208:
                self = .invalidTodo
            case 401:
                self = .unauthorized
            case 404:
                self = .notFound
            case 500...599:
                self = .serverError("Server error: \(code)")
            default:
                self = .networkError("Network error: \(code)")
            }
        default:
            self = .unknown
        }
    }

    var localizedDescription: String {
        switch self {
        case .invalidTodo:
            return "AI가 Todo내용 인식을 실패했어요 :("
        case .invalidURL:
            return "Invalid URL"
        case .noData:
            return "유효한 내용이 입력되지 않았어요"
        case .decodingError:
            return "Failed to decode response"
        case .networkError(let message):
            return message
        case .serverError(let message):
            return message
        case .unauthorized:
            return "로그아웃 후 다시 이용해주세요"
        case .notFound:
            return "Resource not found"
        case .unknown:
            return "An unknown error occurred"
        }
    }
}
