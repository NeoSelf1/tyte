import Foundation
import Alamofire

enum APIError: Error {
    case invalidURL
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
        case .invalidURL:
            return "Invalid URL"
        case .noData:
            return "No data received"
        case .decodingError:
            return "Failed to decode response"
        case .networkError(let message):
            return message
        case .serverError(let message):
            return message
        case .unauthorized:
            return "Unauthorized access"
        case .notFound:
            return "Resource not found"
        case .unknown:
            return "An unknown error occurred"
        }
    }
}
